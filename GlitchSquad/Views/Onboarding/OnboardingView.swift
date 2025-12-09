//
//  OnboardingView.swift
//  GlitchSquad
//
//  A multi-step onboarding flow designed for parents and kids.
//  Explains Privacy, The Story/Goal, and The Mission.
//  Replaces the old cinematic IntroView.
//

import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0
    @State private var isAnimating = false

    // Gradient for primary buttons
    private let primaryGradient = LinearGradient(
        colors: [Color(hex: "00D9FF"), Color(hex: "6366F1")],
        startPoint: .leading,
        endPoint: .trailing
    )

    var body: some View {
        ZStack {
            // Background
            Color(hex: "0D0D1A").ignoresSafeArea()

            // TabView Carousel
            TabView(selection: $currentPage) {
                welcomePrivacyPage
                    .tag(0)

                storyPage
                    .tag(1)

                missionPrepPage
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            // Skip Button (Top Right)
            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        onComplete()
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .padding()
                }
                Spacer()
            }

            // Navigation Controls (Bottom Right Floating Card)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    navigationCard
                        .padding(.trailing, 12)
                        .padding(.bottom, 16)
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // MARK: - Navigation Card

    private var navigationCard: some View {
        Group {
            if horizontalSizeClass == .compact {
                // iPhone: Horizontal layout
                HStack(spacing: 16) {
                    // Title and dots
                    VStack(alignment: .leading, spacing: 6) {
                        Text(currentTitle)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        HStack(spacing: 6) {
                            ForEach(0..<3) { index in
                                Circle()
                                    .fill(
                                        currentPage == index
                                            ? Color(hex: "00D9FF") : Color.white.opacity(0.2)
                                    )
                                    .frame(width: 6, height: 6)
                            }
                        }
                    }

                    // Action Button
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            onComplete()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Text(currentPage == 2 ? "Let's Go!" : "Next")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(primaryGradient)
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "00D9FF").opacity(0.4), radius: 8, x: 0, y: 4)
                    }
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
            } else {
                // iPad: Vertical layout
                VStack(spacing: 20) {
                    Text(currentTitle)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    // Custom Page Indicator
                    HStack(spacing: 8) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(
                                    currentPage == index
                                        ? Color(hex: "00D9FF") : Color.white.opacity(0.2)
                                )
                                .frame(width: 8, height: 8)
                        }
                    }

                    // Action Button
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            onComplete()
                        }
                    }) {
                        HStack {
                            Text(currentPage == 2 ? "Let's Go!" : "Next")
                            Image(systemName: "arrow.right")
                        }
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(primaryGradient)
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "00D9FF").opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 32))
                .overlay(
                    RoundedRectangle(cornerRadius: 32)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
                .frame(width: 200)
            }
        }
    }

    private var currentTitle: String {
        switch currentPage {
        case 0: return "Privacy"
        case 1: return "Meet Pixel!"
        case 2: return "Ready?"
        default: return ""
        }
    }

    // MARK: - Page 1: Privacy & Safety (Parent Focused)

    private var welcomePrivacyPage: some View {
        HStack(spacing: 40) {
            // Left: Privacy Shield Hero
            VStack(spacing: 20) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color(hex: "00FF94"), Color(hex: "00D9FF")],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Color(hex: "00FF94").opacity(0.5), radius: 20)

                Text("100% Private")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(width: 300)

            // Right: Benefits Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                benefitCard(icon: "iphone", title: "Stays on\ndevice", subtitle: "No cloud upload")
                benefitCard(
                    icon: "trash", title: "Deleted\ninstantly", subtitle: "Images never saved")
                benefitCard(
                    icon: "wifi.slash", title: "No internet\nneeded", subtitle: "Works offline")
                benefitCard(icon: "eye.slash", title: "Parents\nonly", subtitle: "Safe for kids")
            }
            .frame(maxWidth: 400)
        }
        .padding()
    }

    private func benefitCard(icon: String, title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundStyle(Color(hex: "00D9FF"))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Page 2: Story (Kid Focused)

    private var storyPage: some View {
        HStack(spacing: 40) {
            // Left: Pixel Character
            ZStack {
                // Glow
                Circle()
                    .fill(Color(hex: "00FF94").opacity(0.2))
                    .frame(width: 250, height: 250)
                    .blur(radius: 40)

                PixelCharacterView(state: .sad, size: 160)
            }
            .frame(width: 280)

            // Right: Narrative
            VStack(alignment: .leading, spacing: 20) {
                Text("Your robot friend needs help!")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)

                Text(
                    "Pixel's base is broken and only YOU can fix it by finding real objects around your home!"
                )
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.8))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    Image(systemName: "target")
                        .foregroundStyle(Color(hex: "FF6B6B"))
                    Text("3 missions to complete today")
                        .foregroundStyle(.white.opacity(0.9))
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                }
            }
            .frame(maxWidth: 350)
            .padding(.trailing, 220)  // Reserve space for navigation card
        }
        .padding(.leading, 20)
    }

    // MARK: - Page 3: Mission Prep

    private var missionPrepPage: some View {
        HStack(spacing: 60) {
            // Left: Mission Items
            VStack(spacing: 30) {
                Text("Find these items to repair:")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                HStack(spacing: 20) {
                    itemCard(emoji: "🍎", name: "Apple", role: "Power Source")
                    itemCard(emoji: "🍌", name: "Banana", role: "Stabilizer")
                    itemCard(emoji: "🍊", name: "Orange", role: "Shield Core")
                }
            }

            // Right: Pixel Waiting
            VStack(spacing: 20) {
                PixelCharacterView(state: .glitching, size: 120)

                Text("Warning:\nCritical Failure")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(hex: "FF6B6B"))
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }

    private func itemCard(emoji: String, name: String, role: String) -> some View {
        VStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 50))
                .shadow(radius: 10)

            VStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(role)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(width: 110, height: 160)
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    OnboardingView(onComplete: {})
        .previewInterfaceOrientation(.landscapeLeft)
}
