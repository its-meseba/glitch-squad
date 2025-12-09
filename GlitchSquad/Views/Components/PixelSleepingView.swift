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

    @State private var moonOffset: CGFloat = 0
    @State private var starsOpacity: Double = 0
    @State private var zzzOffset: CGFloat = 0
    @State private var showParentButton: Bool = false

    var body: some View {
        ZStack {
            // Night sky background
            nightBackground

            // Stars
            starsView

            VStack(spacing: 32) {
                Spacer()

                // Moon
                moonView

                // Sleeping Pixel
                sleepingPixelView

                // Message
                messageView

                // Countdown
                countdownView

                Spacer()

                // Hidden parent override (long press)
                parentOverrideButton
            }
            .padding(.horizontal, 32)
        }
        .onAppear {
            animateScene()
        }
    }

    // MARK: - Night Background

    private var nightBackground: some View {
        LinearGradient(
            colors: [
                Color(hex: "0D0F2B"),
                Color(hex: "1A1F4E"),
                Color(hex: "2D3561"),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Stars

    private var starsView: some View {
        GeometryReader { geo in
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill(.white)
                    .frame(width: CGFloat.random(in: 2...4))
                    .position(
                        x: CGFloat.random(in: 0...geo.size.width),
                        y: CGFloat.random(in: 0...geo.size.height * 0.6)
                    )
                    .opacity(starsOpacity * Double.random(in: 0.3...1.0))
            }
        }
    }

    // MARK: - Moon

    private var moonView: some View {
        ZStack {
            // Glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "FFE066").opacity(0.3),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)

            // Moon
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "FFFACD"), Color(hex: "FFE066")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .shadow(color: Color(hex: "FFE066").opacity(0.5), radius: 20)
        }
        .offset(y: moonOffset)
    }

    // MARK: - Sleeping Pixel

    private var sleepingPixelView: some View {
        ZStack {
            // Pixel character (sleeping pose)
            PixelCharacterView(state: .idle, size: 120)
                .opacity(0.7)
                .saturation(0.5)

            // ZZZ bubbles
            Text("💤")
                .font(.system(size: 40))
                .offset(x: 50, y: -40 + zzzOffset)
                .opacity(0.8)
        }
    }

    // MARK: - Message

    private var messageView: some View {
        VStack(spacing: 12) {
            Text("Pixel is Recharging")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(
                "Great job today, Agent! Pixel needs to rest.\nCome back tomorrow for more missions!"
            )
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.7))
            .multilineTextAlignment(.center)
        }
    }

    // MARK: - Countdown

    private var countdownView: some View {
        VStack(spacing: 8) {
            Text("Energy refills in")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))

            Text(dailyProgress.timeUntilResetFormatted)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "00D9FF"), Color(hex: "00FF94")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Parent Override

    private var parentOverrideButton: some View {
        VStack(spacing: 8) {
            if showParentButton {
                Button(action: onParentOverride) {
                    Text("Parent: Grant Bonus Mission")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(.ultraThinMaterial, in: Capsule())
                }
            } else {
                Text("Hold for parent options")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(.bottom, 40)
        .onLongPressGesture(minimumDuration: 2.0) {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            withAnimation {
                showParentButton = true
            }
        }
    }

    // MARK: - Animation

    private func animateScene() {
        // Stars fade in
        withAnimation(.easeIn(duration: 1.0)) {
            starsOpacity = 1.0
        }

        // Moon float
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            moonOffset = -10
        }

        // ZZZ float
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            zzzOffset = -15
        }
    }
}

// MARK: - Preview

#Preview("Pixel Sleeping") {
    PixelSleepingView(
        dailyProgress: DailyProgress(),
        onParentOverride: {}
    )
}
