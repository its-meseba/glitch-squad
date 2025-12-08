//
//  Mission.swift
//  GlitchSquad
//
//  Mission definitions and Pixel character state for the narrative game flow.
//

import Foundation

// MARK: - Pixel Character State

/// The visual/emotional state of Pixel the robot
enum PixelState: String, CaseIterable {
    case idle  // Normal state, slight bobbing
    case happy  // Mission complete, celebrating
    case sad  // Low battery, needs help
    case glitching  // System error, visual glitch effects

    /// SF Symbol for placeholder (until real images)
    var placeholderSymbol: String {
        switch self {
        case .idle: return "cpu"
        case .happy: return "cpu.fill"
        case .sad: return "exclamationmark.triangle"
        case .glitching: return "bolt.horizontal"
        }
    }

    /// Color for the placeholder icon
    var symbolColor: String {
        switch self {
        case .idle: return "00D9FF"  // Cyan
        case .happy: return "00FF94"  // Green
        case .sad: return "FF6B6B"  // Red
        case .glitching: return "F472B6"  // Pink
        }
    }
}

// MARK: - Mission Definition

/// A single mission in the Glitch Squad game
struct Mission: Identifiable, Equatable {
    let id = UUID()
    let target: TargetFruit
    let title: String
    let narrative: String
    let prompt: String
    let successLine: String
    let rewardBits: Int
    let pixelStateBefore: PixelState
    let pixelStateAfter: PixelState

    /// All missions in the POC campaign
    static let campaign: [Mission] = [
        Mission(
            target: .apple,
            title: "The Power Source",
            narrative: "My battery is almost empty!",
            prompt: "I need RED ENERGY to power up. Find me an APPLE!",
            successLine: "YES! Target acquired! Systems charging...",
            rewardBits: 50,
            pixelStateBefore: .sad,
            pixelStateAfter: .idle
        ),
        Mission(
            target: .banana,
            title: "The Stabilizer",
            narrative: "Whoa! I'm all wobbly!",
            prompt: "I need a YELLOW STABILIZER to fix my balance. Find a BANANA!",
            successLine: "Perfect! My circuits are stabilizing!",
            rewardBits: 75,
            pixelStateBefore: .glitching,
            pixelStateAfter: .idle
        ),
        Mission(
            target: .orange,
            title: "The Shield",
            narrative: "Warning! Virus detected!",
            prompt: "I need CITRUS SHIELDS to fight it off. Quick, find an ORANGE!",
            successLine: "Amazing work, Agent! Virus eliminated!",
            rewardBits: 100,
            pixelStateBefore: .glitching,
            pixelStateAfter: .happy
        ),
    ]
}

// MARK: - Game Progress

/// Tracks overall game progress for persistence
struct GameProgress: Codable {
    var currentMissionIndex: Int = 0
    var totalGlitchBits: Int = 0
    var isPixelRepaired: Bool = false
    var hasSeenIntro: Bool = false

    /// Calculate battery percentage based on completed missions
    var batteryPercentage: Double {
        let baseBattery = 5.0  // Starting at 5%
        let perMission = 30.0  // 30% per mission
        return min(100, baseBattery + Double(currentMissionIndex) * perMission)
    }
}
