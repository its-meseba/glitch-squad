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
    func detect(pixelBuffer: CVPixelBuffer) async -> [DetectionResult]
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

    /// Minimum confidence threshold for detections
    private let confidenceThreshold: Float = 0.85

    /// Labels we care about (fruits only)
    private let targetLabels = Set(["apple", "banana", "orange"])

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
    /// - Parameter pixelBuffer: Camera frame to analyze
    /// - Returns: Array of detected objects (filtered to target fruits)
    func detect(pixelBuffer: CVPixelBuffer) async -> [DetectionResult] {
        if isMockMode {
            return mockDetection()
        }

        return await performVisionDetection(pixelBuffer: pixelBuffer)
    }

    /// Counter for logging frequency
    private var frameCount = 0

    /// Real Vision-based detection
    private func performVisionDetection(pixelBuffer: CVPixelBuffer) async -> [DetectionResult] {
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
                        print("🎯 Object detections:")
                        for obs in observations.prefix(5) {
                            print(
                                "   - \(obs.labels.map { "\($0.identifier): \($0.confidence)" }.joined(separator: ", "))"
                            )
                        }
                    }

                    // Convert to DetectionResult, filtering for target fruits
                    let filtered = observations.compactMap { observation -> DetectionResult? in
                        guard let topLabel = observation.labels.first,
                            topLabel.confidence >= confidenceThreshold,
                            targetLabels.contains(topLabel.identifier.lowercased())
                        else {
                            return nil
                        }

                        return DetectionResult(
                            label: topLabel.identifier.lowercased(),
                            confidence: topLabel.confidence,
                            boundingBox: observation.boundingBox
                        )
                    }

                    if shouldLog && !filtered.isEmpty {
                        print("✅ Matched fruits: \(filtered.map { $0.label })")
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
    private func mockDetection() -> [DetectionResult] {
        mockFrameCount += 1

        // Only "detect" something every ~30 frames (about once per second)
        // This simulates realistic detection patterns
        guard mockFrameCount % 30 == 0 else {
            return []
        }

        // Randomly pick a fruit to "detect"
        let fruits = TargetFruit.allCases
        let randomFruit = fruits.randomElement()!

        // Random 70% chance to actually detect something
        guard Double.random(in: 0...1) > 0.3 else {
            return []
        }

        // Generate random bounding box in center-ish area
        let size = CGFloat.random(in: 0.3...0.5)
        let x = CGFloat.random(in: 0.2...(0.8 - size))
        let y = CGFloat.random(in: 0.2...(0.8 - size))

        return [
            DetectionResult(
                label: randomFruit.label,
                confidence: Float.random(in: 0.7...0.95),
                boundingBox: CGRect(x: x, y: y, width: size, height: size)
            )
        ]
    }
}

// MARK: - Preview Mock Detector

/// A simple mock detector for SwiftUI previews
final class MockDetectorService: ObjectDetecting, Sendable {
    func detect(pixelBuffer: CVPixelBuffer) async -> [DetectionResult] {
        // Return empty for previews - we'll simulate in the view model
        return []
    }
}
