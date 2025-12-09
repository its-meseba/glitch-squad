//
//  PrivacyBadge.swift
//  GlitchSquad
//
//  Visual indicator showing privacy status ("Las Vegas Rule").
//  Photos are processed on-device and deleted instantly.
//

import Network
import SwiftUI

// MARK: - Privacy Badge

/// Floating badge showing privacy/offline status
struct PrivacyBadge: View {

    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var isExpanded: Bool = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isExpanded.toggle()
            }

            // Auto-collapse after 3 seconds
            if isExpanded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        isExpanded = false
                    }
                }
            }
        }) {
            HStack(spacing: 6) {
                // Lock icon
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(hex: "00FF94"))

                if isExpanded {
                    // Expanded text
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Private Mode")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                        Text(networkMonitor.isConnected ? "On-Device Only" : "Offline ✓")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                } else {
                    // Compact indicator
                    Circle()
                        .fill(Color(hex: "00FF94"))
                        .frame(width: 6, height: 6)
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, isExpanded ? 12 : 10)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(Color(hex: "00FF94").opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Network Monitor

/// Monitors network connectivity
class NetworkMonitor: ObservableObject {

    @Published var isConnected: Bool = true

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}

// MARK: - Privacy Info View

/// Full-screen privacy explanation
struct PrivacyInfoView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(hex: "0D0D1A"),
                    Color(hex: "1A1A2E"),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                // Header
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Shield icon
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "00FF94"), Color(hex: "00D9FF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color(hex: "00FF94").opacity(0.5), radius: 30)

                Text("Your Privacy is Protected")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    PrivacyFeatureRow(
                        icon: "iphone",
                        title: "On-Device Processing",
                        description: "Photos are analyzed on this device only"
                    )

                    PrivacyFeatureRow(
                        icon: "trash",
                        title: "Instant Deletion",
                        description: "Camera frames are deleted immediately after scanning"
                    )

                    PrivacyFeatureRow(
                        icon: "wifi.slash",
                        title: "No Internet Required",
                        description: "Works completely offline - no data leaves your device"
                    )

                    PrivacyFeatureRow(
                        icon: "server.rack",
                        title: "No Cloud Storage",
                        description: "We don't store any photos or videos anywhere"
                    )
                }
                .padding(24)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 24)

                Spacer()
                Spacer()
            }
        }
    }
}

struct PrivacyFeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: "00D9FF"))
                .frame(width: 30)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(description)
                    .font(.system(size: 12, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }
}

// MARK: - Preview

#Preview("Privacy Badge") {
    ZStack {
        Color(hex: "1A1A2E")
            .ignoresSafeArea()

        VStack {
            PrivacyBadge()
            Spacer()
        }
        .padding()
    }
}

#Preview("Privacy Info") {
    PrivacyInfoView()
}
