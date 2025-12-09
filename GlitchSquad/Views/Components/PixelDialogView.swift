//
//  PixelDialogView.swift
//  GlitchSquad
//
//  Game-style dialog box showing Pixel's portrait and speech.
//  Adapts to iPhone (compact) and iPad (regular) horizontal screens.
//

import SwiftUI

// MARK: - Pixel Dialog View

/// Game-style dialog box that appears at the bottom of the screen
/// Shows Pixel's portrait with current state and animated text
struct PixelDialogView: View {

    let text: String
    let pixelState: PixelState
    let isVisible: Bool
    var onComplete: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil

    @State private var displayedText: String = ""
    @State private var currentIndex: Int = 0
    @State private var isAnimating: Bool = false
    @State private var showDialog: Bool = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // Adaptive sizing
    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var portraitSize: CGFloat {
        isCompact ? 70 : 100
    }

    private var fontSize: CGFloat {
        isCompact ? 14 : 17
    }

    private var dialogHeight: CGFloat {
        isCompact ? 100 : 130
    }

    var body: some View {
        VStack {
            Spacer()

            if showDialog {
                dialogContent
                    .transition(
                        .asymmetric(
                            insertion: .move(edge: .bottom).combined(with: .opacity),
                            removal: .move(edge: .bottom).combined(with: .opacity)
                        ))
            }
        }
        .onChange(of: isVisible) { _, newValue in
            if newValue {
                showDialogAnimated()
            } else {
                hideDialogAnimated()
            }
        }
        .onAppear {
            if isVisible {
                showDialogAnimated()
            }
        }
    }

    // MARK: - Dialog Content

    private var dialogContent: some View {
        HStack(spacing: 0) {
            // Left: Pixel portrait
            pixelPortrait

            // Right: Text box
            textBox
        }
        .frame(minHeight: dialogHeight)
        .fixedSize(horizontal: false, vertical: true)
        .background(dialogBackground)
        .padding(.horizontal, isCompact ? 12 : 24)
        .padding(.bottom, isCompact ? 8 : 16)
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
    }

    // MARK: - Pixel Portrait

    private var pixelPortrait: some View {
        VStack(spacing: 6) {
            // Character
            ZStack {
                // Glow background
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [stateColor.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: portraitSize / 2
                        )
                    )
                    .frame(width: portraitSize, height: portraitSize)

                // Pixel
                PixelCharacterView(state: pixelState, size: portraitSize * 0.8)
            }

            // Name badge
            Text("PIXEL")
                .font(.system(size: isCompact ? 9 : 11, weight: .bold, design: .rounded))
                .tracking(1)
                .foregroundStyle(.white.opacity(0.7))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(stateColor.opacity(0.3), in: Capsule())
        }
        .frame(width: isCompact ? 90 : 120)
        .padding(.leading, isCompact ? 8 : 16)
    }

    private var stateColor: Color {
        switch pixelState {
        case .idle: return Color(hex: "00D9FF")
        case .happy: return Color(hex: "00FF94")
        case .sad: return Color(hex: "FF6B6B")
        case .glitching: return Color(hex: "FFE066")
        }
    }

    // MARK: - Text Box

    private var textBox: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Dialog text with typewriter effect
            Text(displayedText)
                .font(.system(size: fontSize, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineSpacing(4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, isCompact ? 12 : 16)
                .padding(.horizontal, isCompact ? 12 : 20)

            Spacer()

            // Continue indicator (shows when text is complete)
            if !isAnimating && displayedText.count == text.count {
                HStack {
                    Spacer()
                    ContinueIndicator()
                        .padding(.trailing, isCompact ? 12 : 20)
                        .padding(.bottom, 8)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(textBoxBackground)
        .clipShape(RoundedRectangle(cornerRadius: isCompact ? 16 : 20))
        .padding(.trailing, isCompact ? 8 : 16)
        .padding(.vertical, isCompact ? 8 : 12)
    }

    private var textBoxBackground: some View {
        ZStack {
            // Frosted glass
            RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                .fill(.ultraThinMaterial)

            // Inner glow
            RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.05),
                            Color.clear,
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Border
            RoundedRectangle(cornerRadius: isCompact ? 16 : 20)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.3),
                            Color.white.opacity(0.1),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }

    // MARK: - Background

    private var dialogBackground: some View {
        ZStack {
            // Dark overlay
            RoundedRectangle(cornerRadius: isCompact ? 20 : 28)
                .fill(Color.black.opacity(0.6))

            // Glass effect
            RoundedRectangle(cornerRadius: isCompact ? 20 : 28)
                .fill(.ultraThinMaterial.opacity(0.5))

            // Colored accent border based on state
            RoundedRectangle(cornerRadius: isCompact ? 20 : 28)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            stateColor.opacity(0.6),
                            stateColor.opacity(0.2),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
    }

    // MARK: - Animation Logic

    private func showDialogAnimated() {
        displayedText = ""
        currentIndex = 0
        isAnimating = true

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            showDialog = true
        }

        // Small delay before starting typewriter
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            typeNextCharacter()
        }
    }

    private func hideDialogAnimated() {
        withAnimation(.easeOut(duration: 0.25)) {
            showDialog = false
        }

        // Reset state
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            displayedText = ""
            currentIndex = 0
            isAnimating = false
        }
    }

    private func typeNextCharacter() {
        guard currentIndex < text.count, isVisible else {
            isAnimating = false
            onComplete?()
            return
        }

        let index = text.index(text.startIndex, offsetBy: currentIndex)
        displayedText.append(text[index])
        currentIndex += 1

        // Vary speed based on character
        let char = text[index]
        let delay: Double
        switch char {
        case ".", "!", "?":
            delay = 0.2
        case ",":
            delay = 0.1
        case " ":
            delay = 0.03
        default:
            delay = 0.04
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            typeNextCharacter()
        }
    }

    private func handleTap() {
        if isAnimating {
            // Skip to end
            isAnimating = false
            displayedText = text
            currentIndex = text.count
        } else {
            // Dismiss
            onTap?()
        }
    }
}

// MARK: - Continue Indicator

struct ContinueIndicator: View {
    @State private var bounce: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Text("TAP")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.5))

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color(hex: "00D9FF"))
                .offset(x: bounce ? 3 : 0)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                bounce = true
            }
        }
    }
}

// MARK: - Dialog Overlay Modifier

extension View {
    /// Adds a Pixel dialog overlay to any view
    func pixelDialog(
        text: String,
        pixelState: PixelState,
        isVisible: Binding<Bool>,
        onComplete: (() -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self.overlay(alignment: .bottom) {
            PixelDialogView(
                text: text,
                pixelState: pixelState,
                isVisible: isVisible.wrappedValue,
                onComplete: onComplete,
                onTap: {
                    isVisible.wrappedValue = false
                    onDismiss?()
                }
            )
        }
    }
}

// MARK: - Preview

#Preview("Dialog - iPad") {
    ZStack {
        Color(hex: "0D0D1A").ignoresSafeArea()

        PixelDialogView(
            text: VoiceScript.introGreeting,
            pixelState: .sad,
            isVisible: true
        )
    }
    .previewDevice("iPad Pro 13-inch (M4)")
    .previewInterfaceOrientation(.landscapeLeft)
}

#Preview("Dialog - iPhone") {
    ZStack {
        Color(hex: "0D0D1A").ignoresSafeArea()

        PixelDialogView(
            text: VoiceScript.missionApple,
            pixelState: .glitching,
            isVisible: true
        )
    }
    .previewDevice("iPhone 16 Pro")
    .previewInterfaceOrientation(.landscapeLeft)
}
