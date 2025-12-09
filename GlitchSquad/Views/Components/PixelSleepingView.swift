//
//  PixelSleepingView.swift
//  GlitchSquad
//
//  Displayed when daily energy cap is reached (3 missions).
//  "Pixel is sleeping. Come back tomorrow."
//

import SwiftUI

// MARK: - Pixel Sleeping View

/// Energy cap reached - Pixel needs to rest
struct PixelSleepingView: View {

    let dailyProgress: DailyProgress
    let onParentOverride: () -> Void
    let onBack: (() -> Void)?

    @Environment(\.dismiss) private var dismiss

    @State private var moonOffset: CGFloat = 0
    @State private var starsOpacity: Double = 0
    @State private var zzzOffset: CGFloat = 0
    @State private var showParentButton: Bool = false

    init(
        dailyProgress: DailyProgress, onParentOverride: @escaping () -> Void,
        onBack: (() -> Void)? = nil
    ) {
        self.dailyProgress = dailyProgress
        self.onParentOverride = onParentOverride
        self.onBack = onBack
    }

    var body: some View {
        ZStack {
            // Night sky background (Deep Blue)
            Color(hex: "0D0E25").ignoresSafeArea()

            // Subtle Stars
            starsView

            VStack(spacing: 0) {
                // Top Bar with Back Button
                HStack {
                    Button(action: {
                        if let onBack = onBack {
                            onBack()
                        } else {
                            dismiss()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .foregroundStyle(Color(hex: "00D9FF"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(hex: "1A1F35").opacity(0.8))
                        .clipShape(Capsule())
                    }

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()

                // Main Content - Horizontal Layout
                HStack(spacing: 24) {
                    // LEFT SIDE: Sleeping Pixel with Zzz animation
                    ZStack {
                        // Glow behind
                        Circle()
                            .fill(Color(hex: "00D9FF").opacity(0.15))
                            .frame(width: 150, height: 150)
                            .blur(radius: 25)

                        // Pixel
                        PixelCharacterView(state: .idle, size: 120)
                            .scaleEffect(0.9)
                            .saturation(0.8)

                        // Floating Z animations
                        ZStack {
                            FloatingZ(delay: 0, xOffset: 35, yOffset: -45)
                            FloatingZ(delay: 1.2, xOffset: 50, yOffset: -60)
                            FloatingZ(delay: 2.4, xOffset: 42, yOffset: -75)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // RIGHT SIDE: Text Content
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Pixel is Recharging")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Great job today, Agent!\nPixel needs to rest....")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundStyle(.white.opacity(0.6))
                            .multilineTextAlignment(.leading)
                            .lineSpacing(4)

                        Spacer().frame(height: 8)

                        // Countdown Pill
                        HStack(spacing: 6) {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color(hex: "00D9FF"))

                            Text("Energy refills in")
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))

                            Text(dailyProgress.timeUntilResetFormatted)
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(hex: "00D9FF"))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(hex: "1A1F35"))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 32)

                Spacer()

                // Hidden parent override
                parentOverrideButton
                    .frame(height: 1)  // Minimized but touchable
                    .opacity(0.01)
            }
        }
        .onAppear {
            animateScene()
        }
    }

    // MARK: - Stars

    private var starsView: some View {
        GeometryReader { geo in
            ForEach(0..<20, id: \.self) { i in
                Circle()
                    .fill(.white)
                    .frame(width: CGFloat.random(in: 1...3))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height)
                    )
                    .opacity(Double.random(in: 0.2...0.6))
            }
        }
    }

    // MARK: - Parent Override

    @State private var parentButtonActive: Bool = false

    private var parentOverrideButton: some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .onLongPressGesture(minimumDuration: 3.0) {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                onParentOverride()
            }
    }

    // MARK: - Animation

    private func animateScene() {
        // No global scene animation needed for this cleaner look
    }
}

// MARK: - Floating Z Component

struct FloatingZ: View {
    let delay: Double
    let xOffset: CGFloat
    let yOffset: CGFloat

    @State private var opacity: Double = 0
    @State private var offset: CGFloat = 0

    var body: some View {
        Text("Z")
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundStyle(Color(hex: "4A55A2"))  // Dark Blue Z
            .opacity(opacity)
            .offset(x: xOffset, y: yOffset - offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                ) {
                    opacity = 0
                    offset = 40
                }

                // Fade in entry
                withAnimation(
                    .easeIn(duration: 0.5)
                        .repeatForever(autoreverses: false)
                        .delay(delay)
                ) {
                    opacity = 1
                }
            }
    }
}

// MARK: - Preview

#Preview("Pixel Sleeping") {
    PixelSleepingView(
        dailyProgress: DailyProgress(),
        onParentOverride: {},
        onBack: {}
    )
}
