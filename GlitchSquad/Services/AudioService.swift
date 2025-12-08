//
//  AudioService.swift
//  GlitchSquad
//
//  Handles all audio: sound effects and Pixel's voice lines.
//  Supports both pre-recorded voice files and TTS fallback.
//

import AVFoundation
import SwiftUI

// MARK: - Sound Effect Types

/// Available sound effects in the game
enum SoundEffect: String {
    case glitchStatic = "glitch_static"
    case systemBoot = "system_boot"
    case missionAccept = "mission_accept"
    case targetLock = "target_lock"
    case digitizeScan = "digitize_scan"
    case successPowerup = "success_powerup"
}

/// Available voice lines for Pixel
enum VoiceLine: String {
    case introGreeting = "Voice/intro_greeting"
    case missionApple = "Voice/mission_apple"
    case missionBanana = "Voice/mission_banana"
    case missionOrange = "Voice/mission_orange"
    case success1 = "Voice/success_1"
    case success2 = "Voice/success_2"
    case success3 = "Voice/success_3"
    case gameComplete = "Voice/game_complete"

    /// Get voice line for a specific mission target
    static func forTarget(_ target: TargetFruit) -> VoiceLine {
        switch target {
        case .apple: return .missionApple
        case .banana: return .missionBanana
        case .orange: return .missionOrange
        }
    }

    /// Get a random success line
    static var randomSuccess: VoiceLine {
        [.success1, .success2, .success3].randomElement()!
    }
}

// MARK: - Audio Service

/// Manages all audio playback for the game
@MainActor
final class AudioService: ObservableObject {

    // MARK: - Properties

    /// Audio player for sound effects
    private var sfxPlayer: AVAudioPlayer?

    /// Audio player for voice lines
    private var voicePlayer: AVAudioPlayer?

    /// Speech synthesizer for TTS fallback
    private let synthesizer = AVSpeechSynthesizer()

    /// Whether sound effects are available
    @Published private(set) var sfxAvailable: Bool = false

    /// Whether voice lines are available
    @Published private(set) var voiceLinesAvailable: Bool = false

    /// Current speaking/playing state
    @Published private(set) var isSpeaking: Bool = false

    // MARK: - Initialization

    init() {
        setupAudioSession()
        checkAvailableSounds()
    }

    /// Configure audio session for game audio
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            print("⚠️ AudioService: Failed to setup audio session: \(error)")
        }
    }

    /// Check which sound files are available
    private func checkAvailableSounds() {
        // Check for SFX
        if Bundle.main.url(forResource: SoundEffect.glitchStatic.rawValue, withExtension: "mp3")
            != nil
        {
            sfxAvailable = true
            print("✅ AudioService: Sound effects available")
        } else {
            print("ℹ️ AudioService: No SFX files found")
        }

        // Check for voice lines
        if Bundle.main.url(forResource: VoiceLine.introGreeting.rawValue, withExtension: "mp3")
            != nil
        {
            voiceLinesAvailable = true
            print("✅ AudioService: Voice lines available")
        } else {
            print("ℹ️ AudioService: No voice files found - using TTS fallback")
        }
    }

    // MARK: - Sound Effects

    /// Play a sound effect
    func playSound(_ sound: SoundEffect) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else {
            print("⚠️ AudioService: Sound file not found: \(sound.rawValue).mp3")
            return
        }

        do {
            sfxPlayer = try AVAudioPlayer(contentsOf: url)
            sfxPlayer?.prepareToPlay()
            sfxPlayer?.play()
        } catch {
            print("❌ AudioService: Failed to play sound: \(error)")
        }
    }

    /// Stop any currently playing sound effect
    func stopSound() {
        sfxPlayer?.stop()
        sfxPlayer = nil
    }

    // MARK: - Voice Lines

    /// Play a voice line (or TTS fallback)
    func playVoiceLine(
        _ line: VoiceLine, fallbackText: String? = nil, completion: (() -> Void)? = nil
    ) {
        // Try to play audio file first
        if let url = Bundle.main.url(forResource: line.rawValue, withExtension: "mp3") {
            playVoiceAudio(url: url, completion: completion)
        } else if let text = fallbackText {
            // Fall back to TTS
            speak(text, completion: completion)
        } else {
            // No audio, no fallback - just complete
            completion?()
        }
    }

    /// Play voice audio from URL
    private func playVoiceAudio(url: URL, completion: (() -> Void)?) {
        do {
            voicePlayer = try AVAudioPlayer(contentsOf: url)
            voicePlayer?.prepareToPlay()
            voicePlayer?.play()
            isSpeaking = true

            // Monitor for completion
            Task {
                while voicePlayer?.isPlaying == true {
                    try? await Task.sleep(nanoseconds: 100_000_000)  // 0.1s
                }
                isSpeaking = false
                completion?()
            }
        } catch {
            print("❌ AudioService: Failed to play voice: \(error)")
            completion?()
        }
    }

    // MARK: - Text-to-Speech (Fallback)

    /// Have Pixel speak a message via TTS
    func speak(_ text: String, completion: (() -> Void)? = nil) {
        // Stop any current speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }

        let utterance = AVSpeechUtterance(string: text)

        // Configure robotic voice
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.9
        utterance.pitchMultiplier = 1.2
        utterance.volume = 1.0

        isSpeaking = true
        synthesizer.speak(utterance)

        // Monitor for completion
        Task {
            while synthesizer.isSpeaking {
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
            isSpeaking = false
            completion?()
        }
    }

    /// Stop Pixel from speaking
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        voicePlayer?.stop()
        voicePlayer = nil
        isSpeaking = false
    }

    /// Stop all audio
    func stopAll() {
        stopSound()
        stopSpeaking()
    }

    // MARK: - Convenience Methods

    /// Play intro sequence audio
    func playIntroSequence() {
        playSound(.glitchStatic)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.playSound(.systemBoot)
        }
    }

    /// Play Pixel's intro greeting
    func playIntroGreeting(completion: @escaping () -> Void) {
        playVoiceLine(
            .introGreeting,
            fallbackText:
                "System Failure... Power Critical... Agent, are you there? I'm Pixel. I need your help!",
            completion: completion
        )
    }

    /// Play mission briefing for a mission
    func playMissionBriefing(_ mission: Mission, completion: @escaping () -> Void) {
        let voiceLine = VoiceLine.forTarget(mission.target)
        let fallbackText = "\(mission.narrative) \(mission.prompt)"

        playVoiceLine(voiceLine, fallbackText: fallbackText, completion: completion)
    }

    /// Play lock-on sound
    func playLockOn() {
        playSound(.targetLock)
    }

    /// Play success sequence with voice
    func playSuccessSequence(successLine: String) {
        playSound(.successPowerup)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.playVoiceLine(.randomSuccess, fallbackText: successLine, completion: nil)
        }
    }

    /// Play game complete celebration
    func playGameComplete(completion: (() -> Void)? = nil) {
        playVoiceLine(
            .gameComplete,
            fallbackText:
                "You did it! All systems restored! Thank you, Agent. You're the best repair crew in the galaxy!",
            completion: completion
        )
    }
}
