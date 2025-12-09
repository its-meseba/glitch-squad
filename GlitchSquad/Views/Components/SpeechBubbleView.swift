//
//  SpeechBubbleView.swift
//  GlitchSquad
//
//  Animated speech bubble that appears above Pixel when speaking.
//  Shows the text of voice lines with typewriter animation.
//

import SwiftUI

// MARK: - Speech Bubble View

/// Animated speech bubble for Pixel's voice lines
struct SpeechBubbleView: View {

    let text: String
    let isVisible: Bool

    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    @State private var showBubble: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            if showBubble {
                // Bubble content
                VStack(spacing: 0) {
                    Text(displayedText)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
                .background(
                    ZStack {
                        // Glow effect
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "6366F1").opacity(0.3))
                            .blur(radius: 8)

                        // Main bubble
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)

                        // Border
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "00D9FF").opacity(0.6),
                                        Color(hex: "6366F1").opacity(0.4),
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    }
                )
                .frame(maxWidth: 280)
                .transition(
                    .asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .opacity
                    ))

                // Bubble pointer (triangle)
                Triangle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 16, height: 10)
                    .overlay(
                        Triangle()
                            .stroke(Color(hex: "00D9FF").opacity(0.4), lineWidth: 1.5)
                    )
                    .offset(y: -1)
            }
        }
        .onChange(of: isVisible) { _, newValue in
            if newValue {
                startTypewriter()
            } else {
                hideBubble()
            }
        }
        .onChange(of: text) { _, _ in
            if isVisible {
                startTypewriter()
            }
        }
    }

    // MARK: - Typewriter Animation

    private func startTypewriter() {
        displayedText = ""
        currentIndex = 0

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showBubble = true
        }

        typeNextCharacter()
    }

    private func typeNextCharacter() {
        guard currentIndex < text.count else { return }

        let index = text.index(text.startIndex, offsetBy: currentIndex)
        displayedText.append(text[index])
        currentIndex += 1

        // Vary speed slightly for natural feel
        let delay =
            text[index] == " " ? 0.02 : (text[index] == "." || text[index] == "!" ? 0.15 : 0.04)

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            typeNextCharacter()
        }
    }

    private func hideBubble() {
        withAnimation(.easeOut(duration: 0.2)) {
            showBubble = false
        }
        displayedText = ""
        currentIndex = 0
    }
}

// MARK: - Triangle Shape

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Pixel With Speech Bubble

/// Pixel character with optional speech bubble above
struct PixelWithSpeechBubble: View {

    let state: PixelState
    let size: CGFloat
    let speechText: String?
    let isSpeaking: Bool

    init(
        state: PixelState, size: CGFloat = 100, speechText: String? = nil, isSpeaking: Bool = false
    ) {
        self.state = state
        self.size = size
        self.speechText = speechText
        self.isSpeaking = isSpeaking
    }

    var body: some View {
        VStack(spacing: 8) {
            // Speech bubble
            if let text = speechText {
                SpeechBubbleView(text: text, isVisible: isSpeaking)
            }

            // Pixel character
            PixelCharacterView(state: state, size: size)
        }
    }
}

// MARK: - Voice Line Scripts

/// Contains all voice line scripts for speech bubbles
enum VoiceScript {
    static let introGreeting =
        "System Failure... Power Critical... Agent, are you there? I'm Pixel. I need your help!"

    static let missionApple =
        "My battery is almost empty! I need RED ENERGY to power up. Find me an APPLE! Go go go!"

    static let missionBanana =
        "Whoa! I'm all wobbly! I need a YELLOW STABILIZER to fix my balance. Find a BANANA!"

    static let missionOrange =
        "Warning! Virus detected! I need CITRUS SHIELDS to fight it off. Quick, find an ORANGE!"

    static let success1 = "YES! Target acquired! Systems charging..."

    static let success2 = "Perfect! My circuits are tingling!"

    static let success3 = "Amazing work, Agent! Power levels rising!"

    static let gameComplete =
        "You did it! All systems restored! Thank you, Agent. You're the best repair crew in the galaxy!"

    static var randomSuccess: String {
        [success1, success2, success3].randomElement()!
    }

    static func forMission(_ target: TargetFruit) -> String {
        switch target {
        case .apple: return missionApple
        case .banana: return missionBanana
        case .orange: return missionOrange
        }
    }
}

// MARK: - Preview

#Preview("Speech Bubble") {
    ZStack {
        Color(hex: "0D0D1A").ignoresSafeArea()

        VStack {
            PixelWithSpeechBubble(
                state: .happy,
                size: 120,
                speechText: VoiceScript.introGreeting,
                isSpeaking: true
            )
        }
    }
}
