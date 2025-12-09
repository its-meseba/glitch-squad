//
//  SafeZoneTutorialView.swift
//  GlitchSquad
//
//  First-run tutorial explaining where to search safely.
//  Teaches kids about allowed play areas.
//

import SwiftUI

// MARK: - Safe Zone Tutorial View

/// First-run onboarding teaching safe search areas
struct SafeZoneTutorialView: View {

    let onComplete: () -> Void

    @State private var currentPage: Int = 0

    var body: some View {
        ZStack {
            // Background
            backgroundGradient

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    Button("Skip") {
                        onComplete()
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding()
                }

                // Content
                TabView(selection: $currentPage) {
                    welcomePage.tag(0)
                    safeZonesPage.tag(1)
                    privacyPage.tag(2)
                    readyPage.tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicators and button
                VStack(spacing: 24) {
                    // Dots
                    HStack(spacing: 8) {
                        ForEach(0..<4, id: \.self) { i in
                            Circle()
                                .fill(
                                    i == currentPage
                                        ? Color(hex: "00D9FF") : Color.white.opacity(0.3)
                                )
                                .frame(width: 8, height: 8)
                        }
                    }

                    // Button
                    Button(action: {
                        if currentPage < 3 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            onComplete()
                        }
                    }) {
                        Text(currentPage < 3 ? "Next" : "Let's Go!")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "00D9FF"), Color(hex: "6366F1")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 50)
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "0D0D1A"),
                Color(hex: "1A1A2E"),
                Color(hex: "16213E"),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Page 1: Welcome

    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()

            // Pixel character
            PixelCharacterView(state: .happy, size: 150)

            Text("Meet Pixel!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Your robot friend needs your help!\nHis base is broken and only YOU can fix it.")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Page 2: Safe Zones

    private var safeZonesPage: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🏠")
                .font(.system(size: 80))

            Text("Where to Look")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Search in safe places around your home!")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))

            VStack(alignment: .leading, spacing: 16) {
                SafeZoneRow(emoji: "🍳", name: "Kitchen", isAllowed: true)
                SafeZoneRow(emoji: "🛋️", name: "Living Room", isAllowed: true)
                SafeZoneRow(emoji: "🛏️", name: "Bedroom", isAllowed: true)
                SafeZoneRow(emoji: "🌳", name: "Outside Alone", isAllowed: false)
                SafeZoneRow(emoji: "🚗", name: "Near Roads", isAllowed: false)
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Page 3: Privacy

    private var privacyPage: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "00FF94"), Color(hex: "00D9FF")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("Your Privacy is Safe")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 16) {
                PrivacyRow(icon: "iphone", text: "Photos stay on your device")
                PrivacyRow(icon: "trash", text: "Deleted instantly after scanning")
                PrivacyRow(icon: "wifi.slash", text: "Works without internet")
                PrivacyRow(icon: "eye.slash", text: "No one else can see")
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Page 4: Ready

    private var readyPage: some View {
        VStack(spacing: 32) {
            Spacer()

            PixelCharacterView(state: .glitching, size: 150)

            Text("Help Pixel!")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Find real objects to repair his base.\nComplete 3 missions to fully restore it!")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Mission preview
            HStack(spacing: 16) {
                MissionPreviewBadge(emoji: "🍎", name: "Apple")
                MissionPreviewBadge(emoji: "🍌", name: "Banana")
                MissionPreviewBadge(emoji: "🍊", name: "Orange")
            }

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Supporting Views

struct SafeZoneRow: View {
    let emoji: String
    let name: String
    let isAllowed: Bool

    var body: some View {
        HStack(spacing: 16) {
            Text(emoji)
                .font(.system(size: 28))

            Text(name)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Image(systemName: isAllowed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(isAllowed ? Color(hex: "00FF94") : Color(hex: "FF6B6B"))
        }
    }
}

struct PrivacyRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(Color(hex: "00D9FF"))
                .frame(width: 30)

            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

struct MissionPreviewBadge: View {
    let emoji: String
    let name: String

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 36))

            Text(name)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview("Safe Zone Tutorial") {
    SafeZoneTutorialView(onComplete: {})
}
