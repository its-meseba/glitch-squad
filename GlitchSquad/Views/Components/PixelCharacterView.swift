//
//  PixelCharacterView.swift
//  GlitchSquad
//
//  Animated 2D Pixel character with state-based appearance.
//  Uses generated PNG images from Assets.xcassets.
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
    @State private var glitchOpacity: Double = 1.0

    /// Image name for current state
    private var imageName: String {
        switch state {
        case .idle: return "pixel_idle"
        case .happy: return "pixel_happy"
        case .sad: return "pixel_sad"
        case .glitching: return "pixel_glitch"
        }
    }

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

            // Character image from assets
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .opacity(glitchOpacity)
                .offset(x: isGlitching ? glitchOffset : 0, y: bobOffset)
                // Add subtle glow around the character
                .shadow(color: Color(hex: state.symbolColor).opacity(0.5), radius: 10)
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
        } else {
            glitchOpacity = 1.0
        }
    }

    private func startGlitchAnimation() {
        // Random shake and flicker effect
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if !isGlitching {
                timer.invalidate()
                glitchOffset = 0
                glitchOpacity = 1.0
                return
            }
            glitchOffset = CGFloat.random(in: -3...3)
            // Random flicker
            glitchOpacity = Double.random(in: 0.7...1.0)
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
