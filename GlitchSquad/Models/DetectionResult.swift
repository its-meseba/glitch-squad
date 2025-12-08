//
//  DetectionResult.swift
//  GlitchSquad
//
//  Created for GlitchSquad - A Scavenger Hunt Game for Kids
//

import Foundation
import CoreGraphics

// MARK: - Detection Result

/// Represents a single object detected by the Vision/Core ML pipeline.
/// This is the bridge between DetectorService and GameViewModel.
struct DetectionResult: Identifiable, Equatable {
    let id = UUID()
    
    /// The label of the detected object (e.g., "apple", "banana", "orange")
    let label: String
    
    /// Detection confidence from 0.0 to 1.0
    let confidence: Float
    
    /// Bounding box in normalized coordinates (0.0 to 1.0)
    /// Origin is bottom-left in Vision coordinate system
    let boundingBox: CGRect
    
    /// Convenience: Check if this detection matches a target fruit
    func matches(target: TargetFruit) -> Bool {
        // Case-insensitive comparison
        label.lowercased() == target.label.lowercased()
    }
}

// MARK: - Target Fruit

/// The fruits kids need to find in the scavenger hunt
enum TargetFruit: CaseIterable {
    case apple
    case banana
    case orange
    
    /// The label that matches Core ML model output
    var label: String {
        switch self {
        case .apple: return "apple"
        case .banana: return "banana"
        case .orange: return "orange"
        }
    }
    
    /// Display emoji for the UI
    var emoji: String {
        switch self {
        case .apple: return "🍎"
        case .banana: return "🍌"
        case .orange: return "🍊"
        }
    }
    
    /// Display name for the UI
    var displayName: String {
        switch self {
        case .apple: return "Apple"
        case .banana: return "Banana"
        case .orange: return "Orange"
        }
    }
    
    /// Background gradient colors for each fruit
    var gradientColors: [String] {
        switch self {
        case .apple: return ["#FF6B6B", "#FF8E8E", "#FFB4B4"]
        case .banana: return ["#FFE066", "#FFF0A0", "#FFFBE0"]
        case .orange: return ["#FF9F43", "#FFB976", "#FFD4A8"]
        }
    }
}
