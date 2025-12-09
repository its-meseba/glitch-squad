//
//  DailyProgress.swift
//  GlitchSquad
//
//  Tracks daily mission limits to prevent overuse.
//  Energy Cap: Maximum 3 missions per day.
//

import Foundation

// MARK: - Daily Progress

/// Tracks daily play limits for energy cap feature
struct DailyProgress: Codable {

    /// Number of missions completed today
    var missionsToday: Int = 0

    /// Date of last play session
    var lastPlayDate: Date?

    /// Bonus missions granted by parent
    var bonusMissionsGranted: Int = 0

    /// Maximum missions allowed per day
    static let dailyLimit: Int = 3

    // MARK: - Computed Properties (Non-mutating)

    /// Check if it's a new day (without mutating)
    private var isNewDay: Bool {
        guard let lastDate = lastPlayDate else { return false }
        return !Calendar.current.isDateInToday(lastDate)
    }

    /// Effective missions today (accounts for day reset)
    private var effectiveMissionsToday: Int {
        isNewDay ? 0 : missionsToday
    }

    /// Effective bonus missions (accounts for day reset)
    private var effectiveBonusMissions: Int {
        isNewDay ? 0 : bonusMissionsGranted
    }

    /// Whether child can start a new mission
    var canPlay: Bool {
        effectiveMissionsToday < (Self.dailyLimit + effectiveBonusMissions)
    }

    /// Missions remaining today
    var missionsRemaining: Int {
        max(0, (Self.dailyLimit + effectiveBonusMissions) - effectiveMissionsToday)
    }

    /// Time until energy resets (next midnight)
    var timeUntilReset: TimeInterval {
        let calendar = Calendar.current
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()),
            let midnight = calendar.startOfDay(for: tomorrow) as Date?
        else {
            return 0
        }
        return midnight.timeIntervalSinceNow
    }

    /// Formatted time until reset
    var timeUntilResetFormatted: String {
        let hours = Int(timeUntilReset) / 3600
        let minutes = (Int(timeUntilReset) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }

    // MARK: - Mutations

    /// Record a completed mission
    mutating func recordMission() {
        resetIfNewDay()
        missionsToday += 1
        lastPlayDate = Date()
        save()
    }

    /// Parent grants a bonus mission
    mutating func grantBonusMission() {
        resetIfNewDay()
        bonusMissionsGranted += 1
        save()
    }

    /// Reset counters if it's a new day
    private mutating func resetIfNewDay() {
        if isNewDay {
            missionsToday = 0
            bonusMissionsGranted = 0
        }
    }

    // MARK: - Persistence

    private static let storageKey = "dailyProgress"

    /// Load from UserDefaults (with day reset check)
    static func load() -> DailyProgress {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
            var progress = try? JSONDecoder().decode(DailyProgress.self, from: data)
        else {
            return DailyProgress()
        }
        // Reset if new day
        progress.resetIfNewDay()
        progress.save()
        return progress
    }

    /// Save to UserDefaults
    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }
}
