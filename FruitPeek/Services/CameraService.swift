//
//  CameraService.swift
//  FruitPeek
//
//  Manages AVCaptureSession for live camera feed.
//  Outputs CVPixelBuffer stream for Vision processing.
//

import AVFoundation
import UIKit

// MARK: - Camera Service

/// Manages the device camera and provides a stream of video frames.
/// Uses async/await pattern for modern Swift concurrency.
@MainActor
final class CameraService: NSObject, ObservableObject {

    // MARK: - Published Properties

    /// Current authorization status
    @Published private(set) var authorizationStatus: AVAuthorizationStatus = .notDetermined

    /// Whether the camera session is running
    @Published private(set) var isRunning: Bool = false

    /// Error message if something goes wrong
    @Published var errorMessage: String?

    // MARK: - Camera Components

    /// The capture session managing camera input/output
    let captureSession = AVCaptureSession()

    /// Video output for accessing pixel buffers
    private let videoOutput = AVCaptureVideoDataOutput()

    /// Queue for processing video frames (off main thread for performance)
    private let videoQueue = DispatchQueue(label: "com.fruitpeek.camera", qos: .userInteractive)

    // MARK: - Frame Streaming

    /// Continuation for the async stream of pixel buffers
    private var frameContinuation: AsyncStream<CVPixelBuffer>.Continuation?

    /// Async stream of camera frames for Vision processing
    var frameStream: AsyncStream<CVPixelBuffer> {
        AsyncStream { continuation in
            self.frameContinuation = continuation

            // Clean up when stream is cancelled
            continuation.onTermination = { @Sendable _ in
                Task { @MainActor in
                    self.frameContinuation = nil
                }
            }
        }
    }

    // MARK: - Initialization

    override init() {
        super.init()
        checkAuthorizationStatus()
    }

    // MARK: - Authorization

    /// Check current camera permission status
    private func checkAuthorizationStatus() {
        authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }

    /// Request camera permission from the user
    func requestAuthorization() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        switch status {
        case .authorized:
            authorizationStatus = .authorized
            return true

        case .notDetermined:
            // Ask user for permission
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            authorizationStatus = granted ? .authorized : .denied
            return granted

        case .denied, .restricted:
            authorizationStatus = status
            return false

        @unknown default:
            return false
        }
    }

    // MARK: - Session Setup

    /// Configure the capture session with camera input and video output
    func setupSession() throws {
        // Begin configuration
        captureSession.beginConfiguration()

        // Set session preset for high performance
        captureSession.sessionPreset = .hd1280x720

        // Add camera input
        guard
            let camera = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: .back)
        else {
            throw CameraError.noCameraAvailable
        }

        let input = try AVCaptureDeviceInput(device: camera)

        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        } else {
            throw CameraError.cannotAddInput
        }

        // Configure video output
        videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        } else {
            throw CameraError.cannotAddOutput
        }

        // Set video orientation
        if let connection = videoOutput.connection(with: .video) {
            // Use the new rotation API for iOS 17+
            connection.videoRotationAngle = 90
        }

        // Commit configuration
        captureSession.commitConfiguration()
    }

    // MARK: - Session Control

    /// Start the camera capture session
    func startSession() {
        guard !captureSession.isRunning else { return }

        // Run on background thread to not block UI
        videoQueue.async { [weak self] in
            self?.captureSession.startRunning()

            Task { @MainActor in
                self?.isRunning = true
            }
        }
    }

    /// Stop the camera capture session
    func stopSession() {
        guard captureSession.isRunning else { return }

        videoQueue.async { [weak self] in
            self?.captureSession.stopRunning()

            Task { @MainActor in
                self?.isRunning = false
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraService: AVCaptureVideoDataOutputSampleBufferDelegate {

    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        // Extract pixel buffer from sample buffer
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        // Send to async stream for Vision processing
        Task { @MainActor in
            frameContinuation?.yield(pixelBuffer)
        }
    }
}

// MARK: - Camera Errors

enum CameraError: LocalizedError {
    case noCameraAvailable
    case cannotAddInput
    case cannotAddOutput
    case notAuthorized

    var errorDescription: String? {
        switch self {
        case .noCameraAvailable:
            return "No camera is available on this device."
        case .cannotAddInput:
            return "Could not add camera input to session."
        case .cannotAddOutput:
            return "Could not add video output to session."
        case .notAuthorized:
            return "Camera access is not authorized."
        }
    }
}
