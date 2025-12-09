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
    let successVoice: VoiceLine
    let rewardBits: Int
    let pixelStateBefore: PixelState
    let pixelStateAfter: PixelState

    /// All missions in the POC campaign
    static let campaign: [Mission] = [
        Mission(
            target: .apple,
            title: "The Power Source",
            narrative: "My battery is almost empty!",
            prompt: "I need RED ENERGY to power up. Find me an APPLE! Go go go!",
            successLine: "YES! Target acquired! Systems charging...",
            successVoice: .success1,
            rewardBits: 50,
            pixelStateBefore: .sad,
            pixelStateAfter: .idle
        ),
        Mission(
            target: .banana,
            title: "The Stabilizer",
            narrative: "Whoa! I'm all wobbly!",
            prompt: "I need a YELLOW STABILIZER to fix my balance. Find a BANANA!",
            successLine: "Perfect! My circuits are tingling!",
            successVoice: .success2,
            rewardBits: 75,
            pixelStateBefore: .glitching,
            pixelStateAfter: .idle
        ),
        Mission(
            target: .orange,
            title: "The Shield",
            narrative: "Warning! Virus detected!",
            prompt: "I need CITRUS SHIELDS to fight it off. Quick, find an ORANGE!",
            successLine: "Amazing work, Agent! Power levels rising!",
            successVoice: .success3,
            rewardBits: 100,
            pixelStateBefore: .glitching,
            pixelStateAfter: .happy
        ),
    ]
}

// MARK: - Game Progress

/// The visual stage of the base island
enum BaseStage: Int, Codable, CaseIterable {
    case broken = 0  // Dark, cracked, no life
    case stabilizing = 1  // Some greenery appearing
    case growing = 2  // Vibrant, healthy
    case restored = 3  // Full paradise

    /// Image name in Assets.xcassets
    var imageName: String {
        "base_stage_\(rawValue + 1)"
    }

    /// Display title
    var title: String {
        switch self {
        case .broken: return "Broken"
        case .stabilizing: return "Stabilizing"
        case .growing: return "Growing"
        case .restored: return "Restored"
        }
    }

    /// Calculate stage from completed mission count
    static func fromMissionCount(_ count: Int) -> BaseStage {
        switch count {
        case 0: return .broken
        case 1: return .stabilizing
        case 2: return .growing
        default: return .restored
        }
    }
}

// MARK: - Collected Item

/// A single item collected during gameplay
struct CollectedItem: Identifiable, Codable, Equatable {
    let id: UUID
    let itemType: String  // e.g., "apple", "banana", "orange"
    let collectedAt: Date
    let missionTitle: String

    init(itemType: String, missionTitle: String) {
        self.id = UUID()
        self.itemType = itemType
        self.collectedAt = Date()
        self.missionTitle = missionTitle
    }

    /// Image name for collection display
    var collectionImageName: String {
        "collected_\(itemType)"
    }

    /// Display name
    var displayName: String {
        itemType.capitalized
    }
}

// MARK: - Collectable Item Definition

/// All items that can be collected in the game
struct CollectableItem: Identifiable {
    let id: String  // Same as itemType
    let name: String
    let emoji: String
    let imageName: String

    static let allItems: [CollectableItem] = [
        CollectableItem(id: "apple", name: "Apple", emoji: "🍎", imageName: "collected_apple"),
        CollectableItem(id: "banana", name: "Banana", emoji: "🍌", imageName: "collected_banana"),
        CollectableItem(id: "orange", name: "Orange", emoji: "🍊", imageName: "collected_orange"),
    ]
}

// MARK: - Game Progress

/// Tracks overall game progress for persistence
struct GameProgress: Codable {
    var currentMissionIndex: Int = 0
    var totalGlitchBits: Int = 0
    var isPixelRepaired: Bool = false
    var hasSeenIntro: Bool = false
    var collectedItems: [CollectedItem] = []

    /// Current base stage based on missions completed
    var baseStage: BaseStage {
        BaseStage.fromMissionCount(currentMissionIndex)
    }

    /// Calculate battery percentage based on completed missions
    var batteryPercentage: Double {
        let baseBattery = 5.0  // Starting at 5%
        let perMission = 30.0  // 30% per mission
        return min(100, baseBattery + Double(currentMissionIndex) * perMission)
    }

    /// Check if an item type has been collected
    func hasCollected(itemType: String) -> Bool {
        collectedItems.contains { $0.itemType == itemType }
    }

    /// Add a collected item
    mutating func addCollectedItem(_ item: CollectedItem) {
        if !hasCollected(itemType: item.itemType) {
            collectedItems.append(item)
        }
    }
}
