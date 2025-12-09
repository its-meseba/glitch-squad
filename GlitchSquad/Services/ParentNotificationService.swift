//
//  ParentNotificationService.swift
//  GlitchSquad
//
//  Handles local notifications for parent mission approvals.
//  No server required - all notifications are local.
//

import Foundation
import UserNotifications

// MARK: - Parent Notification Service

/// Manages local notifications for parent-triggered mission requests
@MainActor
class ParentNotificationService: ObservableObject {

    static let shared = ParentNotificationService()

    @Published var isAuthorized: Bool = false

    private let center = UNUserNotificationCenter.current()

    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }

    // MARK: - Authorization

    /// Check current notification authorization status
    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    /// Request notification permission
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
            return granted
        } catch {
            print("Notification authorization error: \(error)")
            return false
        }
    }

    // MARK: - Mission Notifications

    /// Schedule a mission reminder notification
    func scheduleMissionReminder(after delay: TimeInterval = 3600) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "🤖 Pixel Needs Help!"
        content.body = "A new mission is available. Tap to let your child help Pixel!"
        content.sound = .default
        content.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(
            identifier: "mission_reminder",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    /// Schedule daily mission reminder (e.g., at 4 PM)
    func scheduleDailyReminder(hour: Int = 16, minute: Int = 0) {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "🎮 Time for Glitch Squad!"
        content.body = "Pixel is ready for today's adventures. 3 missions available!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error = error {
                print("Failed to schedule daily notification: \(error)")
            }
        }
    }

    /// Cancel all pending notifications
    func cancelAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.setBadgeCount(0)
    }

    /// Clear badge count
    func clearBadge() {
        center.setBadgeCount(0)
    }

    // MARK: - Energy Reset Notification

    /// Schedule notification when energy resets (midnight)
    func scheduleEnergyResetNotification() {
        guard isAuthorized else { return }

        let content = UNMutableNotificationContent()
        content.title = "⚡ Energy Restored!"
        content.body = "Pixel is fully charged and ready for new missions!"
        content.sound = .default

        // Tomorrow at 8 AM
        var dateComponents = DateComponents()
        dateComponents.hour = 8
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "energy_reset",
            content: content,
            trigger: trigger
        )

        center.add(request)
    }
}
