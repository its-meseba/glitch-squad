//
//  PixelCharacterView.swift
//  GlitchSquad
//
//  Animated 2D Pixel character with state-based appearance.
//  Uses SF Symbols as placeholders until real images are added.
//

import SwiftUI

// MARK: - Pixel Character View

/// The Pixel robot character with animations based on state
struct PixelCharacterView: View {

    let state: PixelState
    var size: CGFloat = 120

    // Animation states
    @State private var bobOffset: CGFloat = 0
    @State private var glitchOffset: CGFloat = 0
    @State private var isGlitching: Bool = false

    var body: some View {
        ZStack {
            // Glow effect behind character
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: state.symbolColor).opacity(0.4),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.7
                    )
                )
                .frame(width: size * 1.4, height: size * 1.4)
                .blur(radius: 20)

            // Character body (glass container)
            ZStack {
                // Body background
                RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: size, height: size)
                    .overlay {
                        RoundedRectangle(cornerRadius: size * 0.25, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color(hex: state.symbolColor).opacity(0.6),
                                        Color(hex: state.symbolColor).opacity(0.2),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    }

                // Face / Icon
                VStack(spacing: 8) {
                    // Eyes (two circles or icon)
                    HStack(spacing: size * 0.15) {
                        Circle()
                            .fill(Color(hex: state.symbolColor))
                            .frame(width: size * 0.18, height: size * 0.18)
                            .shadow(color: Color(hex: state.symbolColor).opacity(0.8), radius: 5)

                        Circle()
                            .fill(
                                state == .glitching
                                    ? Color.white.opacity(0.3) : Color(hex: state.symbolColor)
                            )
                            .frame(width: size * 0.18, height: size * 0.18)
                            .shadow(color: Color(hex: state.symbolColor).opacity(0.8), radius: 5)
                            .overlay {
                                if state == .glitching {
                                    // Static noise effect
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.white.opacity(0.5), .gray.opacity(0.3)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .mask(Circle())
                                }
                            }
                    }

                    // Mouth
                    if state == .happy {
                        // Happy smile
                        Capsule()
                            .fill(Color(hex: state.symbolColor))
                            .frame(width: size * 0.3, height: size * 0.08)
                    } else if state == .sad {
                        // Sad curve
                        Capsule()
                            .fill(Color(hex: state.symbolColor).opacity(0.5))
                            .frame(width: size * 0.2, height: size * 0.06)
                    } else {
                        // Neutral line
                        Capsule()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: size * 0.25, height: size * 0.05)
                    }
                }

                // Antenna
                VStack(spacing: 0) {
                    Circle()
                        .fill(Color(hex: state.symbolColor))
                        .frame(width: size * 0.1, height: size * 0.1)
                        .shadow(color: Color(hex: state.symbolColor), radius: 4)

                    Rectangle()
                        .fill(Color.white.opacity(0.5))
                        .frame(width: 2, height: size * 0.12)
                }
                .offset(y: -size * 0.55)
            }
            .offset(x: isGlitching ? glitchOffset : 0, y: bobOffset)
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: state) { _, _ in
            startAnimations()
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        // Bobbing animation (always active)
        withAnimation(
            .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            bobOffset = state == .sad ? 2 : 5
        }

        // Glitch animation (only for glitching state)
        isGlitching = state == .glitching
        if isGlitching {
            startGlitchAnimation()
        }
    }

    private func startGlitchAnimation() {
        // Random shake effect
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if !isGlitching {
                timer.invalidate()
                glitchOffset = 0
                return
            }
            glitchOffset = CGFloat.random(in: -3...3)
        }
    }
}

// MARK: - Pixel Speaking Bubble

/// Speech bubble that appears when Pixel talks
struct PixelSpeechBubble: View {

    let text: String
    var maxWidth: CGFloat = 300

    @State private var displayedText: String = ""
    @State private var textIndex: Int = 0

    var body: some View {
        Text(displayedText)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .frame(maxWidth: maxWidth)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(.white.opacity(0.3), lineWidth: 1)
                    }
            }
            .onAppear {
                typewriterEffect()
            }
    }

    private func typewriterEffect() {
        displayedText = ""
        textIndex = 0

        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            if textIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: textIndex)
                displayedText += String(text[index])
                textIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Preview

#Preview("Pixel States") {
    ZStack {
        LinearGradient(
            colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack(spacing: 40) {
            HStack(spacing: 30) {
                VStack {
                    PixelCharacterView(state: .idle)
                    Text("Idle").foregroundStyle(.white)
                }
                VStack {
                    PixelCharacterView(state: .happy)
                    Text("Happy").foregroundStyle(.white)
                }
            }
            HStack(spacing: 30) {
                VStack {
                    PixelCharacterView(state: .sad)
                    Text("Sad").foregroundStyle(.white)
                }
                VStack {
                    PixelCharacterView(state: .glitching)
                    Text("Glitching").foregroundStyle(.white)
                }
            }
        }
    }
}

#Preview("Speech Bubble") {
    ZStack {
        Color.black.ignoresSafeArea()
        PixelSpeechBubble(text: "System Failure... Power Critical... Agent, are you there?")
    }
}
