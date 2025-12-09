//
//  IntroView.swift
//  GlitchSquad
//
//  The opening sequence: glitch static reveals Pixel who asks for help.
//  Auto-advances to Mission Briefing after TTS completes.
//

import SwiftUI

// MARK: - Intro View

/// Opening cinematic: glitch effect reveals Pixel who speaks to the player
struct IntroView: View {

    @ObservedObject var audioService: AudioService
    let onComplete: () -> Void

    // Animation states
    @State private var showGlitch: Bool = true
    @State private var pixelOpacity: Double = 0
    @State private var pixelOffset: CGFloat = 100
    @State private var showSpeechBubble: Bool = false
    @State private var speechText: String = ""

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient

            // Glitch static overlay
            if showGlitch {
                GlitchStaticOverlay()
                    .transition(.opacity)
            }

            // Main content
            VStack(spacing: 30) {
                Spacer()

                // Pixel character
                PixelCharacterView(state: .sad, size: 150)
                    .opacity(pixelOpacity)
                    .offset(y: pixelOffset)

                // Speech bubble
                if showSpeechBubble {
                    PixelSpeechBubble(text: speechText, maxWidth: 350)
                        .transition(.scale.combined(with: .opacity))
                        .padding(.horizontal, 40)
                }

                Spacer()

                // Skip button (subtle)
                Button(action: {
                    audioService.stopAll()
                    onComplete()
                }) {
                    Text("Tap to skip")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.bottom, 40)
                .opacity(pixelOpacity)
            }
        }
        .onAppear {
            startIntroSequence()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ZStack {
            // Dark base
            Color(hex: "0D0D1A")
                .ignoresSafeArea()

            // Broken base background image
            Image("broken_base")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .opacity(0.8)

            // Overlay gradient for depth
            LinearGradient(
                colors: [
                    Color.black.opacity(0.3),
                    Color.clear,
                    Color.black.opacity(0.5),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Intro Sequence

    private func startIntroSequence() {
        // Phase 1: Glitch static (1.5s)
        audioService.playSound(.glitchStatic)

        // Phase 2: Clear static, reveal Pixel (0.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.5)) {
                showGlitch = false
            }

            audioService.playSound(.systemBoot)

            // Pixel slides up
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                pixelOpacity = 1
                pixelOffset = 0
            }
        }

        // Phase 3: Show speech bubble and speak (after 2.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            speechText =
                "System Failure... Power Critical... Agent, are you there? I'm Pixel. I need your help!"

            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showSpeechBubble = true
            }

            // Speak the intro
            audioService.playIntroGreeting {
                // After speech, auto-advance
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    onComplete()
                }
            }
        }
    }
}

// MARK: - Glitch Static Overlay

/// Visual noise/static effect for intro
struct GlitchStaticOverlay: View {

    @State private var noiseOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base dark
                Color.black

                // Horizontal scan lines
                VStack(spacing: 2) {
                    ForEach(0..<100, id: \.self) { _ in
                        Rectangle()
                            .fill(Color.white.opacity(Double.random(in: 0.02...0.08)))
                            .frame(height: CGFloat.random(in: 1...4))
                    }
                }
                .offset(y: noiseOffset)

                // Random noise blocks
                ForEach(0..<20, id: \.self) { _ in
                    Rectangle()
                        .fill(Color.white.opacity(Double.random(in: 0.05...0.15)))
                        .frame(
                            width: CGFloat.random(in: 50...200),
                            height: CGFloat.random(in: 2...8)
                        )
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height)
                        )
                }

                // RGB split text
                Text("SYSTEM ERROR")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(.red.opacity(0.5))
                    .offset(x: -2, y: -1)

                Text("SYSTEM ERROR")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(.cyan.opacity(0.5))
                    .offset(x: 2, y: 1)

                Text("SYSTEM ERROR")
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
        .ignoresSafeArea()
        .onAppear {
            // Animate noise
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                noiseOffset = CGFloat.random(in: -10...10)
            }
        }
    }
}

// MARK: - Preview

#Preview("Intro") {
    IntroView(audioService: AudioService()) {
        print("Intro complete!")
    }
}
