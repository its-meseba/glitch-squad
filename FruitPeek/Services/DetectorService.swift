//
//  DetectorService.swift
//  FruitPeek
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
    private let confidenceThreshold: Float = 0.5

    /// Labels we care about (fruits only)
    private let targetLabels = Set(["apple", "banana", "orange"])

    // MARK: - Initialization

    init() {
        setupModel()
    }

    /// Set up the Core ML model for Vision
    private func setupModel() {
        // Try to load the YOLO model (yolov8n.mlpackage compiles to yolov8n.mlmodelc)
        guard let modelURL = Bundle.main.url(forResource: "yolov8n", withExtension: "mlmodelc")
        else {
            print("⚠️ yolov8n model not found - using mock detector")
            isMockMode = true
            return
        }

        do {
            // Load the Core ML model
            let mlModel = try MLModel(contentsOf: modelURL)
            let vnModel = try VNCoreMLModel(for: mlModel)

            // Create Vision request
            detectionRequest = VNCoreMLRequest(model: vnModel) { [weak self] request, error in
                if let error = error {
                    print("Detection error: \(error.localizedDescription)")
                }
            }

            // Configure request for best accuracy
            detectionRequest?.imageCropAndScaleOption = .scaleFill

            print("✅ YOLOv8 model loaded successfully")

        } catch {
            print("⚠️ Failed to load model: \(error.localizedDescription)")
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

    /// Real Vision-based detection
    private func performVisionDetection(pixelBuffer: CVPixelBuffer) async -> [DetectionResult] {
        guard let request = detectionRequest else {
            return []
        }

        // Create image request handler
        let handler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

        do {
            try handler.perform([request])

            // Parse results
            guard let observations = request.results as? [VNRecognizedObjectObservation] else {
                return []
            }

            // Convert to DetectionResult, filtering for target fruits
            return observations.compactMap { observation -> DetectionResult? in
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

        } catch {
            print("Vision detection failed: \(error.localizedDescription)")
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
