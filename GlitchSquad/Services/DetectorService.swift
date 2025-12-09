//
//  DetectorService.swift
//  GlitchSquad
//
//  Handles Core ML object detection using Vision framework.
//  Falls back to mock detector for testing if model not available.
//

import CoreImage
import CoreML
import UIKit
import Vision

// MARK: - Detector Protocol

/// Protocol for object detection to allow mock implementations
@preconcurrency
protocol ObjectDetecting: Sendable {
    /// Detect objects in the pixel buffer
    /// - Parameters:
    ///   - pixelBuffer: Camera frame to analyze
    ///   - targetFruit: The specific fruit label to look for (e.g., "apple")
    ///   - scanningZone: Normalized rect (0-1) defining the detection zone
    /// - Returns: Array of detected objects matching the target
    func detect(pixelBuffer: CVPixelBuffer, targetFruit: String, scanningZone: CGRect) async
        -> [DetectionResult]
}

// MARK: - Detector Service

/// Main detector service using Core ML and Vision framework.
/// Runs detection on a background actor to keep UI smooth at 60/120Hz.
actor DetectorService: ObjectDetecting {

    // MARK: - Properties

    /// Vision request for Core ML model
    private var detectionRequest: VNCoreMLRequest?

    /// Whether using mock detector (model not found)
    private(set) var isMockMode: Bool = false

    /// Minimum confidence threshold for detections (higher to reduce false positives)
    private let confidenceThreshold: Float = 0.95

    /// Minimum confidence margin between top label and second label
    /// Ensures we have a "clear winner" and not ambiguous classification
    private let confidenceMargin: Float = 0.25

    /// Maximum bounding box area (0-1) - reject if detection covers too much of frame
    /// Full-frame classifications often have box ~1.0, real detections are smaller
    private let maxBoundingBoxArea: CGFloat = 0.7

    // model name to load
    private let modelName = "yolo11l"
    // MARK: - Initialization

    init() {
        // Use Task to call actor-isolated method from nonisolated init
        Task { await self.setupModel() }
    }

    /// Set up the Core ML model for Vision
    private func setupModel() {
        // Debug: List all bundle resources
        print("🔍 Searching for model in bundle...")
        if let bundlePath = Bundle.main.resourcePath {
            print("📁 Bundle path: \(bundlePath)")
        }

        // Try compiled model first (.mlmodelc)
        if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlmodelc") {
            print("✅ Found compiled model: \(modelURL)")
            loadModel(from: modelURL)
            return
        }

        // Try mlpackage
        if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "mlpackage") {
            print("✅ Found mlpackage: \(modelURL)")
            loadModel(from: modelURL)
            return
        }

        // Try without extension
        if let modelURL = Bundle.main.url(forResource: modelName, withExtension: nil) {
            print("✅ Found model (no ext): \(modelURL)")
            loadModel(from: modelURL)
            return
        }

        print("⚠️ \(modelName) model not found in bundle - using mock detector")
        print("📋 Available resources:")
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: nil) {
            for url in urls.prefix(20) {
                print("   - \(url.lastPathComponent)")
            }
        }
        isMockMode = true
    }

    private func loadModel(from url: URL) {
        do {
            // Load the Core ML model
            let config = MLModelConfiguration()
            config.computeUnits = .all
            let mlModel = try MLModel(contentsOf: url, configuration: config)

            print("📊 Model loaded, creating Vision model...")
            let vnModel = try VNCoreMLModel(for: mlModel)

            // Create Vision request
            detectionRequest = VNCoreMLRequest(model: vnModel) { request, error in
                if let error = error {
                    print("❌ Detection error: \(error.localizedDescription)")
                }
            }

            // Configure request for best accuracy
            detectionRequest?.imageCropAndScaleOption = .scaleFill

            print("✅ \(modelName) model ready for detection!")

        } catch {
            print("❌ Failed to load model: \(error)")
            isMockMode = true
        }
    }

    // MARK: - Detection

    /// Perform object detection on a camera frame
    /// - Parameters:
    ///   - pixelBuffer: Camera frame to analyze
    ///   - targetFruit: The specific fruit to detect (e.g., "apple")
    ///   - scanningZone: Normalized rect defining where to look
    /// - Returns: Array of detected objects matching the target fruit inside the zone
    func detect(pixelBuffer: CVPixelBuffer, targetFruit: String, scanningZone: CGRect) async
        -> [DetectionResult]
    {
        if isMockMode {
            return mockDetection(targetFruit: targetFruit)
        }

        return await performVisionDetection(
            pixelBuffer: pixelBuffer, targetFruit: targetFruit, scanningZone: scanningZone)
    }

    /// Counter for logging frequency
    private var frameCount = 0

    /// Real Vision-based detection
    private func performVisionDetection(
        pixelBuffer: CVPixelBuffer, targetFruit: String, scanningZone: CGRect
    ) async -> [DetectionResult] {
        guard let request = detectionRequest else {
            print("❌ No detection request available")
            return []
        }

        frameCount += 1

        // Create image request handler
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

        do {
            try handler.perform([request])

            // Log every 30 frames to avoid spam
            let shouldLog = frameCount % 30 == 0

            // Check all possible result types
            if let results = request.results {
                if shouldLog {
                    print("📊 Frame \(frameCount): Got \(results.count) results")
                }

                // Try as VNRecognizedObjectObservation (YOLO object detection)
                if let observations = results as? [VNRecognizedObjectObservation] {
                    if shouldLog && !observations.isEmpty {
                        print("🎯 Object detections (looking for \(targetFruit)):")
                        for obs in observations.prefix(3) {
                            let topLabels = obs.labels.prefix(3).map {
                                "\($0.identifier): \(String(format: "%.2f", $0.confidence))"
                            }
                            print(
                                "   - [\(String(format: "%.2f", obs.boundingBox.width * obs.boundingBox.height))area] \(topLabels.joined(separator: ", "))"
                            )
                        }
                    }

                    // Convert to DetectionResult with strict filtering:
                    // 1. Only current target fruit
                    // 2. High confidence threshold
                    // 3. Clear confidence margin (not ambiguous)
                    // 4. Reasonable bounding box size (not full-frame)
                    // 5. Detection center must be inside scanning zone
                    let filtered = observations.compactMap { observation -> DetectionResult? in
                        // Check bounding box is inside scanning zone (center point check)
                        let centerX = observation.boundingBox.midX
                        let centerY = observation.boundingBox.midY
                        guard scanningZone.contains(CGPoint(x: centerX, y: centerY)) else {
                            return nil
                        }

                        // Check bounding box size - reject if too large (likely classification, not detection)
                        let boxArea = observation.boundingBox.width * observation.boundingBox.height
                        guard boxArea < maxBoundingBoxArea else {
                            if shouldLog {
                                print(
                                    "⚠️ Rejected: bounding box too large (\(String(format: "%.2f", boxArea)) > \(maxBoundingBoxArea))"
                                )
                            }
                            return nil
                        }

                        // Check we have at least one label
                        guard let topLabel = observation.labels.first else {
                            return nil
                        }

                        // Check confidence threshold
                        guard topLabel.confidence >= confidenceThreshold else {
                            return nil
                        }

                        // Check it matches the current target (case-insensitive)
                        guard topLabel.identifier.lowercased() == targetFruit.lowercased() else {
                            return nil
                        }

                        // Check confidence margin - top label should be clearly dominant
                        if let secondLabel = observation.labels.dropFirst().first {
                            let margin = topLabel.confidence - secondLabel.confidence
                            guard margin >= confidenceMargin else {
                                if shouldLog {
                                    print(
                                        "⚠️ Rejected: low margin (\(String(format: "%.2f", margin)) < \(confidenceMargin))"
                                    )
                                }
                                return nil
                            }
                        }

                        return DetectionResult(
                            label: topLabel.identifier.lowercased(),
                            confidence: topLabel.confidence,
                            boundingBox: observation.boundingBox
                        )
                    }

                    if shouldLog && !filtered.isEmpty {
                        print("✅ Valid \(targetFruit) detection: \(filtered.count) found in zone")
                    }

                    return filtered
                }

                // Try as VNClassificationObservation (image classification)
                if let classifications = results as? [VNClassificationObservation] {
                    if shouldLog {
                        print("📋 Classifications:")
                        for cls in classifications.prefix(5) {
                            print("   - \(cls.identifier): \(cls.confidence)")
                        }
                    }
                }

                // Unknown result type
                if shouldLog {
                    print("❓ Unknown result type: \(type(of: results.first))")
                }
            }

            return []

        } catch {
            print("❌ Vision detection failed: \(error)")
            return []
        }
    }

    // MARK: - Mock Detection (for testing)

    /// Random frame counter for mock detection timing
    private var mockFrameCount = 0

    /// Provides mock detections for testing when model unavailable
    private func mockDetection(targetFruit: String) -> [DetectionResult] {
        mockFrameCount += 1

        // Only "detect" something every ~30 frames (about once per second)
        // This simulates realistic detection patterns
        guard mockFrameCount % 30 == 0 else {
            return []
        }

        // Random 70% chance to actually detect the target
        guard Double.random(in: 0...1) > 0.3 else {
            return []
        }

        // Generate random bounding box in center-ish area (inside typical scanning zone)
        let size = CGFloat.random(in: 0.2...0.4)
        let x = CGFloat.random(in: 0.3...(0.7 - size))
        let y = CGFloat.random(in: 0.3...(0.7 - size))

        return [
            DetectionResult(
                label: targetFruit.lowercased(),
                confidence: Float.random(in: 0.95...0.99),
                boundingBox: CGRect(x: x, y: y, width: size, height: size)
            )
        ]
    }
}

// MARK: - Preview Mock Detector

/// A simple mock detector for SwiftUI previews
final class MockDetectorService: ObjectDetecting, Sendable {
    func detect(pixelBuffer: CVPixelBuffer, targetFruit: String, scanningZone: CGRect) async
        -> [DetectionResult]
    {
        // Return empty for previews - we'll simulate in the view model
        return []
    }
}
