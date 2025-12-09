//
//  ParentSettings.swift
//  GlitchSquad
//
//  Parent preferences and authentication.
//

import Foundation

// MARK: - Parent Settings

/// Parent preferences and PIN authentication
struct ParentSettings: Codable {

    /// Parent PIN for authentication (4 digits)
    var pin: String?

    /// Whether notifications are enabled
    var notificationsEnabled: Bool = true

    /// Whether weekly summary is enabled
    var weeklySummaryEnabled: Bool = true

    /// Allowed play zones (for future use)
    var allowedZones: [String] = ["kitchen", "living_room", "bedroom"]

    /// Whether parent has completed setup
    var hasCompletedSetup: Bool {
        pin != nil
    }

    // MARK: - Authentication

    /// Verify PIN
    func verifyPin(_ input: String) -> Bool {
        guard let savedPin = pin else { return false }
        return savedPin == input
    }

    /// Set new PIN
    mutating func setPin(_ newPin: String) {
        guard newPin.count == 4, newPin.allSatisfy({ $0.isNumber }) else {
            return
        }
        pin = newPin
        save()
    }

    // MARK: - Persistence

    private static let storageKey = "parentSettings"

    /// Load from UserDefaults
    static func load() -> ParentSettings {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
            let settings = try? JSONDecoder().decode(ParentSettings.self, from: data)
        else {
            return ParentSettings()
        }
        return settings
    }

    /// Save to UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}

// MARK: - Activity Log Entry

/// Single entry in activity log
struct ActivityLogEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let type: ActivityType
    let details: String

    enum ActivityType: String, Codable {
        case missionStarted
        case missionCompleted
        case parentOverride
        case bonusGranted
        case appOpened
    }

    init(type: ActivityType, details: String) {
        self.id = UUID()
        self.date = Date()
        self.type = type
        self.details = details
    }
}

// MARK: - Activity Log

/// Tracks all activity for parent reporting
class ActivityLog: Codable {

    var entries: [ActivityLogEntry] = []

    /// Add new entry
    func log(_ type: ActivityLogEntry.ActivityType, details: String) {
        let entry = ActivityLogEntry(type: type, details: details)
        entries.append(entry)

        // Keep only last 100 entries
        if entries.count > 100 {
            entries.removeFirst(entries.count - 100)
        }

        save()
    }

    /// Get entries for today
    var todayEntries: [ActivityLogEntry] {
        let calendar = Calendar.current
        return entries.filter { calendar.isDateInToday($0.date) }
    }

    /// Get entries for this week
    var weekEntries: [ActivityLogEntry] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.date > weekAgo }
    }

    // MARK: - Persistence

    private static let storageKey = "activityLog"

    static func load() -> ActivityLog {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
            let log = try? JSONDecoder().decode(ActivityLog.self, from: data)
        else {
            return ActivityLog()
        }
        return log
    }

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
