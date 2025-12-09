//
//  SafeZoneTutorialView.swift
//  GlitchSquad
//
//  First-run tutorial explaining where to search safely.
//  Optimized for iPad/iPhone horizontal (landscape) orientation.
//

import SwiftUI

// MARK: - Safe Zone Tutorial View

/// First-run onboarding teaching safe search areas
/// Redesigned for horizontal/landscape orientation
struct SafeZoneTutorialView: View {

    let onComplete: () -> Void

    @State private var currentPage: Int = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                backgroundGradient

                // Main horizontal layout
                HStack(spacing: 0) {
                    // Left side - Main content (70%)
                    contentSection
                        .frame(width: geometry.size.width * 0.70)

                    // Right side - Navigation controls (30%)
                    navigationSection
                        .frame(width: geometry.size.width * 0.30)
                }
            }
        }
        .ignoresSafeArea()
    }

    // MARK: - Content Section (Left 70%)

    private var contentSection: some View {
        ZStack {
            TabView(selection: $currentPage) {
                welcomePageHorizontal.tag(0)
                safeZonesPageHorizontal.tag(1)
                privacyPageHorizontal.tag(2)
                readyPageHorizontal.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .padding(.leading, 40)
        .padding(.vertical, 20)
    }

    // MARK: - Navigation Section (Right 30%)

    private var navigationSection: some View {
        VStack {
            // Skip button (top right)
            HStack {
                Spacer()
                Button("Skip") {
                    onComplete()
                }
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }

            Spacer()

            // Navigation card
            VStack(spacing: 20) {
                // Page title
                Text(pageTitles[currentPage])
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                // Page dots
                HStack(spacing: 6) {
                    ForEach(0..<4, id: \.self) { i in
                        Circle()
                            .fill(
                                i == currentPage
                                    ? Color(hex: "00D9FF") : Color.white.opacity(0.3)
                            )
                            .frame(width: 8, height: 8)
                    }
                }

                // Next button (compact)
                Button(action: {
                    if currentPage < 3 {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            currentPage += 1
                        }
                    } else {
                        onComplete()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(currentPage < 3 ? "Next" : "Let's Go!")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "00D9FF"), Color(hex: "6366F1")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: Capsule()
                    )
                    .shadow(color: Color(hex: "00D9FF").opacity(0.3), radius: 10, x: 0, y: 4)
                }
            }
            .padding(24)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private var pageTitles: [String] {
        ["Meet Pixel!", "Safe Zones", "Privacy", "Ready?"]
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
    }

    // MARK: - Page 1: Welcome (Horizontal)

    private var welcomePageHorizontal: some View {
        HStack(spacing: 40) {
            // Pixel character on left
            PixelCharacterView(state: .happy, size: 180)
                .shadow(color: Color(hex: "00FF94").opacity(0.3), radius: 30, x: 0, y: 10)

            // Text content on right
            VStack(alignment: .leading, spacing: 16) {
                Text("Your robot friend needs help!")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(
                    "Pixel's base is broken and only YOU can fix it by finding real objects around your home!"
                )
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
                .lineSpacing(4)

                // Mission count badge
                HStack(spacing: 8) {
                    Image(systemName: "target")
                        .foregroundStyle(Color(hex: "FF6B6B"))
                    Text("3 missions to complete")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(.top, 8)
            }
            .padding(.trailing, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Page 2: Safe Zones (Horizontal)

    private var safeZonesPageHorizontal: some View {
        HStack(spacing: 32) {
            // House icon on left
            VStack(spacing: 16) {
                Text("🏠")
                    .font(.system(size: 80))
                Text("Search at\nHome")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 140)

            // Safe zones grid on right
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    SafeZoneCompactRow(emoji: "🍳", name: "Kitchen", isAllowed: true)
                    SafeZoneCompactRow(emoji: "🛋️", name: "Living Room", isAllowed: true)
                }
                HStack(spacing: 12) {
                    SafeZoneCompactRow(emoji: "🛏️", name: "Bedroom", isAllowed: true)
                    SafeZoneCompactRow(emoji: "🌳", name: "Outside Alone", isAllowed: false)
                }
            }
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Page 3: Privacy (Horizontal)

    private var privacyPageHorizontal: some View {
        HStack(spacing: 40) {
            // Shield icon on left
            VStack(spacing: 16) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "00FF94"), Color(hex: "00D9FF")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("100%\nPrivate")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 140)

            // Privacy points grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                PrivacyCompactCard(icon: "iphone", text: "Stays on device")
                PrivacyCompactCard(icon: "trash", text: "Deleted instantly")
                PrivacyCompactCard(icon: "wifi.slash", text: "No internet needed")
                PrivacyCompactCard(icon: "eye.slash", text: "Parents only")
            }
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Page 4: Ready (Horizontal)

    private var readyPageHorizontal: some View {
        HStack(spacing: 40) {
            // Pixel glitching on left
            VStack(spacing: 12) {
                PixelCharacterView(state: .glitching, size: 150)
                    .shadow(color: Color(hex: "FF6B6B").opacity(0.4), radius: 20, x: 0, y: 8)

                Text("⚠️ Critical!")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "FF6B6B"))
            }
            .frame(width: 180)

            // Mission objectives on right
            VStack(alignment: .leading, spacing: 20) {
                Text("Find these items to repair:")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                HStack(spacing: 16) {
                    MissionPreviewCard(emoji: "🍎", name: "Apple", description: "Power Source")
                    MissionPreviewCard(emoji: "🍌", name: "Banana", description: "Stabilizer")
                    MissionPreviewCard(emoji: "🍊", name: "Orange", description: "Shield Core")
                }
            }
            .padding(.trailing, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Supporting Views (Compact for Horizontal)

struct SafeZoneCompactRow: View {
    let emoji: String
    let name: String
    let isAllowed: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 24))

            Text(name)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)

            Spacer()

            Image(systemName: isAllowed ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 20))
                .foregroundStyle(isAllowed ? Color(hex: "00FF94") : Color(hex: "FF6B6B"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .frame(minWidth: 160)
    }
}

struct PrivacyCompactCard: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(Color(hex: "00D9FF"))
                .frame(width: 24)

            Text(text)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct MissionPreviewCard: View {
    let emoji: String
    let name: String
    let description: String

    var body: some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 36))

            Text(name)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(description)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Legacy Supporting Views (kept for compatibility)

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

#Preview("Safe Zone Tutorial - Horizontal") {
    SafeZoneTutorialView(onComplete: {})
        .previewInterfaceOrientation(.landscapeLeft)
}
