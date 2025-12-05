//
//  LiquidUIComponents.swift
//  FruitPeek
//
//  Reusable UI components with "Liquid Glass iOS 26" aesthetic.
//  Glassmorphism, vibrant gradients, and smooth animations.
//

import SwiftUI

// MARK: - Glass Card

/// A frosted glass card container with beautiful blur effects.
/// Use this to wrap any content that should appear on a glass layer.
struct GlassCard<Content: View>: View {

    let content: Content
    var cornerRadius: CGFloat = 30
    var padding: CGFloat = 24

    init(
        cornerRadius: CGFloat = 30,
        padding: CGFloat = 24,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.5),
                                        .white.opacity(0.2),
                                        .clear,
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
            }
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Lock-On Ring

/// Circular progress indicator that fills up during object lock-on.
/// Animates smoothly with gradient stroke and glow effect.
struct LockOnRing: View {

    let progress: Double
    var size: CGFloat = 200
    var lineWidth: CGFloat = 12

    // Gradient colors for the ring
    private let gradientColors: [Color] = [
        Color(hex: "00D9FF"),
        Color(hex: "00FF94"),
        Color(hex: "BDFF00"),
    ]

    var body: some View {
        ZStack {
            // Background ring (subtle)
            Circle()
                .stroke(
                    Color.white.opacity(0.2),
                    lineWidth: lineWidth
                )

            // Progress ring with gradient
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: gradientColors),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.1), value: progress)

            // Glow effect
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    gradientColors[1].opacity(0.5),
                    style: StrokeStyle(
                        lineWidth: lineWidth + 8,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .blur(radius: 12)
                .animation(.easeInOut(duration: 0.1), value: progress)

            // Percentage text
            VStack(spacing: 4) {
                Text("\(Int(progress * 100))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("%")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Confetti Particle

/// Single confetti particle for celebration effect
struct ConfettiParticle: View {

    let color: Color
    @State private var position: CGPoint = .zero
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(color)
            .frame(width: 8, height: 16)
            .rotationEffect(.degrees(rotation))
            .offset(x: position.x, y: position.y)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 3)) {
                    position = CGPoint(
                        x: CGFloat.random(in: -200...200),
                        y: CGFloat.random(in: 300...600)
                    )
                    rotation = Double.random(in: 0...720)
                    opacity = 0
                }
            }
    }
}

// MARK: - Confetti View

/// Full-screen confetti celebration effect
struct ConfettiView: View {

    @State private var particles: [(id: Int, color: Color)] = []

    private let confettiColors: [Color] = [
        Color(hex: "FF6B6B"),
        Color(hex: "FFE066"),
        Color(hex: "4ECDC4"),
        Color(hex: "A855F7"),
        Color(hex: "F472B6"),
        Color(hex: "00D9FF"),
    ]

    var body: some View {
        ZStack {
            ForEach(particles, id: \.id) { particle in
                ConfettiParticle(color: particle.color)
            }
        }
        .onAppear {
            // Generate particles
            for i in 0..<50 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.02) {
                    particles.append((id: i, color: confettiColors.randomElement()!))
                }
            }
        }
    }
}

// MARK: - Fruit Card

/// Beautiful card displaying the target fruit to find
struct FruitCard: View {

    let fruit: TargetFruit
    var isCompact: Bool = false

    var body: some View {
        VStack(spacing: isCompact ? 12 : 20) {
            // Emoji
            Text(fruit.emoji)
                .font(.system(size: isCompact ? 60 : 100))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

            // Name
            Text("Find \(fruit.displayName)!")
                .font(.system(size: isCompact ? 20 : 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
        }
        .padding(isCompact ? 20 : 40)
        .background {
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: fruit.gradientColors.map {
                            Color(hex: $0.replacingOccurrences(of: "#", with: ""))
                        },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .overlay {
            RoundedRectangle(cornerRadius: 40, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.6), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        }
        .shadow(
            color: Color(hex: fruit.gradientColors[0].replacingOccurrences(of: "#", with: ""))
                .opacity(0.4), radius: 30, x: 0, y: 15)
    }
}

// MARK: - Timer Display

/// Countdown timer with visual urgency indicator
struct TimerDisplay: View {

    let timeRemaining: Int

    private var isUrgent: Bool {
        timeRemaining <= 10
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "timer")
                .font(.system(size: 18, weight: .semibold))

            Text("\(timeRemaining)s")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .monospacedDigit()
        }
        .foregroundStyle(isUrgent ? .white : .white.opacity(0.9))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background {
            Capsule()
                .fill(isUrgent ? Color.red.opacity(0.8) : .ultraThinMaterial)
        }
        .animation(.easeInOut(duration: 0.3), value: isUrgent)
    }
}

// MARK: - Score Display

/// Shows current score and total
struct ScoreDisplay: View {

    let score: Int
    let total: Int

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "star.fill")
                .foregroundStyle(.yellow)

            Text("\(score)/\(total)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
        }
    }
}

// MARK: - Ready Button

/// Playful "Ready?" button to start the hunt
struct ReadyButton: View {

    let action: () -> Void

    @State private var isPressed = false
    @State private var isPulsing = false

    var body: some View {
        Button(action: {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                action()
            }
        }) {
            HStack(spacing: 12) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 22, weight: .bold))

                Text("Ready?")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 18)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "6366F1"),
                                Color(hex: "8B5CF6"),
                                Color(hex: "A855F7"),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(isPulsing ? 1.05 : 1.0)
            }
            .shadow(color: Color(hex: "8B5CF6").opacity(0.5), radius: 15, x: 0, y: 8)
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Success Overlay

/// Celebration overlay when fruit is found
struct SuccessOverlay: View {

    let fruit: TargetFruit

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // Dim background
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            // Confetti
            ConfettiView()

            // Success card
            VStack(spacing: 24) {
                Text("🎉")
                    .font(.system(size: 80))

                Text("Found it!")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(fruit.emoji)
                    .font(.system(size: 60))
            }
            .padding(40)
            .background {
                RoundedRectangle(cornerRadius: 40, style: .continuous)
                    .fill(.ultraThinMaterial)
            }
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Game Over View

/// Final screen when all fruits are found
struct GameOverView: View {

    let score: Int
    let total: Int
    let onRestart: () -> Void

    @State private var animateIn = false

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(hex: "1A1A2E"),
                    Color(hex: "16213E"),
                    Color(hex: "0F3460"),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                // Trophy
                Text("🏆")
                    .font(.system(size: 100))
                    .scaleEffect(animateIn ? 1 : 0.5)
                    .opacity(animateIn ? 1 : 0)

                // Score
                VStack(spacing: 8) {
                    Text("Amazing!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("You found \(score) out of \(total) fruits!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .opacity(animateIn ? 1 : 0)

                // All fruits
                HStack(spacing: 20) {
                    ForEach(TargetFruit.allCases, id: \.label) { fruit in
                        Text(fruit.emoji)
                            .font(.system(size: 50))
                    }
                }
                .opacity(animateIn ? 1 : 0)

                // Play again button
                Button(action: onRestart) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Play Again")
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "00D9FF"), Color(hex: "00FF94")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .shadow(color: Color(hex: "00D9FF").opacity(0.5), radius: 15, x: 0, y: 8)
                }
                .opacity(animateIn ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                animateIn = true
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    /// Create color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Previews

#Preview("Glass Card") {
    ZStack {
        LinearGradient(
            colors: [.purple, .blue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        GlassCard {
            VStack {
                Text("🍎")
                    .font(.system(size: 80))
                Text("Hello World")
                    .font(.title)
                    .bold()
            }
        }
    }
}

#Preview("Lock-On Ring") {
    ZStack {
        Color.black.ignoresSafeArea()
        LockOnRing(progress: 0.75)
    }
}

#Preview("Fruit Card") {
    ZStack {
        Color.gray.ignoresSafeArea()
        FruitCard(fruit: .apple)
    }
}

#Preview("Ready Button") {
    ZStack {
        Color.black.ignoresSafeArea()
        ReadyButton {}
    }
}
