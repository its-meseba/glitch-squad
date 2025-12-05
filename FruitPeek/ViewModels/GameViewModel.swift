//
//  GameViewModel.swift
//  FruitPeek
//
//  The brain of the game - manages state machine, confidence bucket,
//  and coordinates camera/detection services.
//

import AVFoundation
import Combine
import SwiftUI

// MARK: - Game State

/// The current state of the scavenger hunt game
enum GameState: Equatable {
    case goal  // Showing target fruit card with "Ready?" button
    case hunt  // Camera active, timer counting down
    case lockOn  // Object detected, filling confidence meter
    case success  // Found it! Celebration time
    case gameOver  // All fruits found - game complete
}

// MARK: - Game View Model

/// Central game logic coordinator using MVVM pattern.
/// Manages the state machine, confidence bucket, and all game mechanics.
@MainActor
final class GameViewModel: ObservableObject {

    // MARK: - Published State

    /// Current game state for UI binding
    @Published private(set) var gameState: GameState = .goal

    /// Current fruit to find
    @Published private(set) var currentTarget: TargetFruit = .apple

    /// Time remaining in hunt phase (seconds)
    @Published private(set) var timeRemaining: Int = 30

    /// Lock-on progress from 0.0 to 1.0 (100% = success)
    @Published private(set) var lockOnProgress: Double = 0.0

    /// Current score (fruits found)
    @Published private(set) var score: Int = 0

    /// Total fruits in the game
    @Published private(set) var totalFruits: Int = 3

    /// Whether camera is authorized
    @Published private(set) var isCameraAuthorized: Bool = false

    /// Latest detection for showing bounding box
    @Published private(set) var currentDetection: DetectionResult?

    // MARK: - Services

    let cameraService: CameraService
    private let detector: DetectorService

    // MARK: - Private State

    /// Fruits remaining to find
    private var fruitsToFind: [TargetFruit] = TargetFruit.allCases.shuffled()

    /// Task for frame processing
    private var processingTask: Task<Void, Never>?

    /// Timer for countdown
    private var gameTimer: Timer?

    /// Timer for confidence decay/update
    private var confidenceTimer: Timer?

    /// Whether correct object was detected this frame
    private var objectDetectedThisFrame: Bool = false

    // MARK: - Configuration

    /// How much confidence increases per detection (per frame)
    private let confidenceIncrement: Double = 0.05  // 5% per update

    /// How much confidence decays when object lost (per frame)
    private let confidenceDecay: Double = 0.03  // 3% per update

    /// Starting time for hunt phase
    private let huntDuration: Int = 30

    // MARK: - Initialization

    init(
        cameraService: CameraService = CameraService(),
        detector: DetectorService = DetectorService()
    ) {
        self.cameraService = cameraService
        self.detector = detector

        // Set first target
        if let first = fruitsToFind.first {
            currentTarget = first
        }
    }

    // MARK: - Public Actions

    /// Called when app launches - setup camera
    func onAppear() async {
        // Request camera permission
        isCameraAuthorized = await cameraService.requestAuthorization()

        if isCameraAuthorized {
            do {
                try cameraService.setupSession()
            } catch {
                print("Camera setup failed: \(error.localizedDescription)")
            }
        }
    }

    /// Called when player taps "Ready?" button
    func startHunt() {
        guard gameState == .goal else { return }

        // Transition to hunt state
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            gameState = .hunt
        }

        // Reset timer
        timeRemaining = huntDuration
        lockOnProgress = 0.0

        // Start camera
        cameraService.startSession()

        // Start processing frames
        startFrameProcessing()

        // Start countdown timer
        startGameTimer()

        // Start confidence update timer (runs at 20Hz for smooth animation)
        startConfidenceTimer()

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    /// Move to next fruit or end game
    func nextRound() {
        // Remove found fruit
        fruitsToFind.removeFirst()

        if fruitsToFind.isEmpty {
            // Game complete!
            gameState = .gameOver
        } else {
            // Set next target
            currentTarget = fruitsToFind[0]
            lockOnProgress = 0.0
            currentDetection = nil

            // Back to goal state
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                gameState = .goal
            }
        }
    }

    /// Reset the entire game
    func resetGame() {
        // Stop everything
        stopAllTimers()
        stopFrameProcessing()
        cameraService.stopSession()

        // Reset state
        fruitsToFind = TargetFruit.allCases.shuffled()
        currentTarget = fruitsToFind[0]
        score = 0
        lockOnProgress = 0.0
        timeRemaining = huntDuration
        currentDetection = nil

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            gameState = .goal
        }
    }

    // MARK: - Frame Processing

    /// Start processing camera frames for object detection
    private func startFrameProcessing() {
        processingTask = Task {
            for await pixelBuffer in cameraService.frameStream {
                guard !Task.isCancelled else { break }

                // Run detection on actor (background)
                let detections = await detector.detect(pixelBuffer: pixelBuffer)

                // Back on main thread, update state
                await MainActor.run {
                    processDetections(detections)
                }
            }
        }
    }

    /// Stop frame processing task
    private func stopFrameProcessing() {
        processingTask?.cancel()
        processingTask = nil
    }

    /// Process detection results
    private func processDetections(_ detections: [DetectionResult]) {
        // Find if current target is detected
        let targetDetection = detections.first { $0.matches(target: currentTarget) }

        if let detection = targetDetection {
            // Target found!
            objectDetectedThisFrame = true
            currentDetection = detection

            // Transition to lock-on if not already
            if gameState == .hunt {
                withAnimation(.easeInOut(duration: 0.2)) {
                    gameState = .lockOn
                }
            }
        } else {
            objectDetectedThisFrame = false
            currentDetection = nil
        }
    }

    // MARK: - Confidence Bucket Logic

    /// Start timer for updating confidence (called at 20Hz)
    private func startConfidenceTimer() {
        confidenceTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) {
            [weak self] _ in
            Task { @MainActor [weak self] in
                self?.updateConfidence()
            }
        }
    }

    /// Update confidence based on detection status
    private func updateConfidence() {
        guard gameState == .hunt || gameState == .lockOn else { return }

        if objectDetectedThisFrame {
            // Increment confidence
            lockOnProgress = min(1.0, lockOnProgress + confidenceIncrement)

            // Check for success!
            if lockOnProgress >= 1.0 {
                triggerSuccess()
            }
        } else {
            // Decay confidence
            lockOnProgress = max(0.0, lockOnProgress - confidenceDecay)

            // If lost completely, go back to hunt
            if lockOnProgress <= 0.0 && gameState == .lockOn {
                withAnimation(.easeInOut(duration: 0.2)) {
                    gameState = .hunt
                }
            }
        }
    }

    // MARK: - Game Timer

    /// Start the countdown timer
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tickTimer()
            }
        }
    }

    /// Handle timer tick
    private func tickTimer() {
        guard gameState == .hunt || gameState == .lockOn else { return }

        timeRemaining -= 1

        if timeRemaining <= 0 {
            // Time's up! Move to next fruit without scoring
            handleTimeout()
        }

        // Warning haptic at 10 seconds
        if timeRemaining == 10 {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }

    /// Handle when time runs out
    private func handleTimeout() {
        stopAllTimers()
        stopFrameProcessing()
        cameraService.stopSession()

        // Automatically move to next round after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.nextRound()
        }
    }

    // MARK: - Success

    /// Triggered when confidence reaches 100%
    private func triggerSuccess() {
        // Stop timers
        stopAllTimers()
        stopFrameProcessing()
        cameraService.stopSession()

        // Update score
        score += 1

        // Transition to success state
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            gameState = .success
        }

        // Success haptics
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        // Auto-advance after celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.nextRound()
        }
    }

    // MARK: - Cleanup

    /// Stop all timers
    private func stopAllTimers() {
        gameTimer?.invalidate()
        gameTimer = nil
        confidenceTimer?.invalidate()
        confidenceTimer = nil
    }

    deinit {
        // Note: This won't be called on MainActor
        // Cleanup is handled in resetGame()
    }
}

// MARK: - Preview Helper

extension GameViewModel {
    /// Create a preview instance with mocked state
    static func preview(state: GameState = .goal, progress: Double = 0.0) -> GameViewModel {
        let vm = GameViewModel()
        vm.gameState = state
        vm.lockOnProgress = progress
        return vm
    }
}
