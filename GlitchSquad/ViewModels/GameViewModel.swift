//
//  GameViewModel.swift
//  GlitchSquad
//
//  The brain of the game - manages state machine, confidence bucket,
//  mission progression, and coordinates all services.
//

import AVFoundation
import Combine
import SwiftUI

// MARK: - Game State

/// The current state of the Glitch Squad game
enum GameState: Equatable {
    case intro  // Opening cinematic with Pixel
    case missionBriefing  // Pixel explains the mission
    case goal  // (Legacy - not used in new flow)
    case hunt  // Camera active, searching for target
    case lockOn  // Object detected, filling confidence meter
    case digitizing  // Capture animation
    case success  // Mission complete celebration
    case gameOver  // All missions done - Pixel repaired!
}

// MARK: - Game View Model

/// Central game logic coordinator using MVVM pattern.
/// Manages state machine, missions, confidence bucket, and all game mechanics.
@MainActor
final class GameViewModel: ObservableObject {

    // MARK: - Published State

    /// Current game state for UI binding
    @Published private(set) var gameState: GameState = .intro

    /// Current fruit to find
    @Published private(set) var currentTarget: TargetFruit = .apple

    /// Time remaining in hunt phase (seconds)
    @Published private(set) var timeRemaining: Int = 60

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

    /// Current mission being played
    @Published private(set) var currentMission: Mission = Mission.campaign[0]

    /// Current mission index (0-2)
    @Published private(set) var currentMissionIndex: Int = 0

    /// Total Glitch Bits earned
    @Published private(set) var glitchBits: Int = 0

    /// Pixel's current state (for character display)
    @Published private(set) var pixelState: PixelState = .sad

    /// Whether the intro has been seen
    @AppStorage("hasSeenIntro") private var hasSeenIntro: Bool = false

    // MARK: - Services

    let cameraService: CameraService
    private let detector: DetectorService

    // MARK: - Private State

    /// Missions remaining
    private var missionsRemaining: [Mission] = Mission.campaign

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
    private let huntDuration: Int = 60

    // MARK: - Initialization

    init(
        cameraService: CameraService? = nil,
        detector: DetectorService? = nil
    ) {
        self.cameraService = cameraService ?? CameraService()
        self.detector = detector ?? DetectorService()

        // Set first mission
        if let first = missionsRemaining.first {
            currentMission = first
            currentTarget = first.target
            pixelState = first.pixelStateBefore
        }
    }

    // MARK: - Public Actions

    /// Called when app launches - setup camera and determine starting state
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

        // Determine starting state
        if hasSeenIntro {
            // Skip intro on subsequent launches
            gameState = .missionBriefing
        } else {
            gameState = .intro
        }
    }

    /// Called when intro animation completes
    func completeIntro() {
        hasSeenIntro = true

        withAnimation(.easeInOut(duration: 0.5)) {
            gameState = .missionBriefing
        }
    }

    /// Called when player taps "Accept Mission" button
    func startHunt() {
        guard gameState == .missionBriefing || gameState == .goal else { return }

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

    /// Called when digitize animation completes
    func completeDigitize() {
        // Update Pixel's state briefly
        pixelState = currentMission.pixelStateAfter

        // Transition to success
        withAnimation(.easeInOut(duration: 0.3)) {
            gameState = .success
        }
    }

    /// Move to next mission or end game
    func nextRound() {
        // Remove completed mission
        missionsRemaining.removeFirst()

        if missionsRemaining.isEmpty {
            // Game complete!
            withAnimation {
                gameState = .gameOver
            }
        } else {
            // Set next mission
            currentMission = missionsRemaining[0]
            currentTarget = currentMission.target
            currentMissionIndex += 1
            pixelState = currentMission.pixelStateBefore
            lockOnProgress = 0.0
            currentDetection = nil

            // Back to briefing
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                gameState = .missionBriefing
            }
        }
    }

    /// Reset the entire game
    func resetGame() {
        // Stop everything
        stopAllTimers()
        stopFrameProcessing()
        cameraService.stopSession()

        // Reset mission state
        missionsRemaining = Mission.campaign
        currentMission = missionsRemaining[0]
        currentTarget = currentMission.target
        currentMissionIndex = 0
        pixelState = currentMission.pixelStateBefore

        // Reset score
        score = 0
        glitchBits = 0
        lockOnProgress = 0.0
        timeRemaining = huntDuration
        currentDetection = nil

        // Start from briefing (not intro on replay)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            gameState = .missionBriefing
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

        // Update score and bits
        score += 1
        glitchBits += currentMission.rewardBits

        // Transition to digitizing state
        withAnimation(.easeInOut(duration: 0.2)) {
            gameState = .digitizing
        }

        // Success haptics
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
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
    static func preview(state: GameState = .missionBriefing, progress: Double = 0.0)
        -> GameViewModel
    {
        let vm = GameViewModel()
        vm.gameState = state
        vm.lockOnProgress = progress
        return vm
    }
}
