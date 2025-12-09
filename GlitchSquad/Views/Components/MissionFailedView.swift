//
//  MissionFailedView.swift
//  GlitchSquad
//
//  Displayed when the timer runs out without finding the target.
//  Does NOT count against daily mission limit - user can try again.
//

import SwiftUI

// MARK: - Mission Failed View

/// Shown when time runs out. User can retry the same mission.
struct MissionFailedView: View {

    let targetName: String
    let targetEmoji: String
    let onTryAgain: () -> Void
    let onGoBack: () -> Void

    @State private var shakeOffset: CGFloat = 0
    @State private var glitchOpacity: Double = 0
    @State private var showContent: Bool = false

    var body: some View {
        ZStack {
            // Dark overlay with glitch effect
            Color(hex: "0D0E25").ignoresSafeArea()

            // Glitch lines
            glitchLines
                .opacity(glitchOpacity)

            VStack(spacing: 32) {
                Spacer()

                // Pixel looking sad
                ZStack {
                    // Glow behind
                    Circle()
                        .fill(Color(hex: "FF6B6B").opacity(0.2))
                        .frame(width: 160, height: 160)
                        .blur(radius: 30)

                    PixelCharacterView(state: .sad, size: 120)
                        .offset(x: shakeOffset)
                }

                // Message
                VStack(spacing: 16) {
                    Text("Time's Up!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(
                        "Couldn't find the \(targetName) this time.\nDon't worry, you can try again!"
                    )
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                }

                // Target reminder
                HStack(spacing: 12) {
                    Text(targetEmoji)
                        .font(.system(size: 36))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("TARGET")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.5))

                        Text(targetName)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .background(Color(hex: "1A1F35"))
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Spacer()

                // Action buttons
                VStack(spacing: 16) {
                    // Try Again button (Primary)
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onTryAgain()
                    }) {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 18, weight: .bold))

                            Text("Try Again")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color(hex: "00D9FF"), Color(hex: "00FF94")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: RoundedRectangle(cornerRadius: 20)
                        )
                    }

                    // Go Back button (Secondary)
                    Button(action: {
                        onGoBack()
                    }) {
                        Text("Go Back to Base")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.vertical, 12)
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
            .opacity(showContent ? 1 : 0)
        }
        .onAppear {
            animateIn()
        }
    }

    // MARK: - Glitch Lines

    private var glitchLines: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                ForEach(0..<20, id: \.self) { i in
                    Rectangle()
                        .fill(Color(hex: "FF6B6B").opacity(Double.random(in: 0.1...0.3)))
                        .frame(height: CGFloat.random(in: 1...3))
                        .offset(x: CGFloat.random(in: -20...20))
                        .padding(.vertical, CGFloat.random(in: 5...30))
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    // MARK: - Animations

    private func animateIn() {
        // Shake Pixel
        withAnimation(.easeInOut(duration: 0.08).repeatCount(6, autoreverses: true)) {
            shakeOffset = 8
        }

        // Glitch flash
        withAnimation(.easeIn(duration: 0.2)) {
            glitchOpacity = 1
        }
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            glitchOpacity = 0.3
        }

        // Show content
        withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
            showContent = true
        }

        // Reset shake
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            shakeOffset = 0
        }
    }
}

// MARK: - Preview

#Preview("Mission Failed") {
    MissionFailedView(
        targetName: "Apple",
        targetEmoji: "🍎",
        onTryAgain: {},
        onGoBack: {}
    )
}
