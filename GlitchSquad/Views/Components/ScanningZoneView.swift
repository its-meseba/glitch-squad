//
//  ScanningZoneView.swift
//  GlitchSquad
//
//  A large scanning zone frame where kids place objects for detection.
//  Features animated glowing border and integrated progress ring.
//

import SwiftUI

// MARK: - Scanning Zone View

/// Large scanning zone frame for object placement and detection.
/// Kids place the target object inside this zone for lock-on to begin.
struct ScanningZoneView: View {

    // MARK: - Properties

    /// Lock-on progress from 0.0 to 1.0
    let progress: Double

    /// Whether object is currently detected in zone
    let isObjectDetected: Bool

    /// Size of the zone as percentage of screen width (0.0 to 1.0)
    var zoneSizeRatio: CGFloat = 0.65

    /// Animation state for pulsing effect
    @State private var isPulsing = false

    /// Animation state for scanning line
    @State private var scanLineOffset: CGFloat = 0

    // MARK: - Colors

    private let inactiveColor = Color.white.opacity(0.4)
    private let activeColors: [Color] = [
        Color(hex: "00D9FF"),
        Color(hex: "00FF94"),
    ]

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            let zoneSize = min(geometry.size.width, geometry.size.height) * zoneSizeRatio

            ZStack {
                // Main zone frame
                zoneFrame(size: zoneSize)

                // Progress ring overlay (appears during lock-on)
                if isObjectDetected && progress > 0 {
                    progressRing(size: zoneSize)
                }

                // Scanning line animation (when searching)
                if !isObjectDetected {
                    scanningLine(size: zoneSize)
                }

                // Corner accents
                cornerAccents(size: zoneSize)
            }
            .frame(width: zoneSize, height: zoneSize)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
        .onAppear {
            startAnimations()
        }
    }

    // MARK: - Zone Frame

    @ViewBuilder
    private func zoneFrame(size: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .strokeBorder(
                isObjectDetected
                    ? LinearGradient(
                        colors: activeColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    : LinearGradient(
                        colors: [inactiveColor, inactiveColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                lineWidth: isObjectDetected ? 4 : 3
            )
            .background {
                // Subtle fill when active
                if isObjectDetected {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(Color(hex: "00FF94").opacity(0.05))
                }
            }
            .shadow(
                color: isObjectDetected
                    ? Color(hex: "00FF94").opacity(0.4)
                    : Color.clear,
                radius: 20
            )
            .scaleEffect(isPulsing && !isObjectDetected ? 1.02 : 1.0)
            .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isPulsing)
    }

    // MARK: - Progress Ring

    @ViewBuilder
    private func progressRing(size: CGFloat) -> some View {
        ZStack {
            // Background track
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .stroke(Color.white.opacity(0.2), lineWidth: 8)
                .frame(width: size, height: size)

            // Progress track
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: activeColors + [activeColors[0]]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .animation(.easeOut(duration: 0.15), value: progress)

            // Glow effect
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .trim(from: 0, to: progress)
                .stroke(
                    Color(hex: "00FF94").opacity(0.5),
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .blur(radius: 10)
                .animation(.easeOut(duration: 0.15), value: progress)

            // Percentage display
            VStack(spacing: 4) {
                Text("\(Int(progress * 100))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("%")
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
    }

    // MARK: - Scanning Line

    @ViewBuilder
    private func scanningLine(size: CGFloat) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color(hex: "00D9FF").opacity(0.6),
                        Color.clear,
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: size - 20, height: 2)
            .offset(y: scanLineOffset)
            .mask {
                RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .frame(width: size - 10, height: size - 10)
            }
    }

    // MARK: - Corner Accents

    @ViewBuilder
    private func cornerAccents(size: CGFloat) -> some View {
        let cornerSize: CGFloat = 40
        let offset = size / 2 - cornerSize / 2 - 5

        ForEach(0..<4, id: \.self) { corner in
            ScanningCornerAccent(
                isActive: isObjectDetected,
                activeColors: activeColors
            )
            .frame(width: cornerSize, height: cornerSize)
            .rotationEffect(.degrees(Double(corner) * 90))
            .offset(
                x: corner == 0 || corner == 3 ? -offset : offset,
                y: corner == 0 || corner == 1 ? -offset : offset
            )
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        // Start pulsing
        isPulsing = true

        // Scanning line animation
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: true)) {
            scanLineOffset = 100
        }
    }
}

// MARK: - Scanning Corner Accent

/// Corner bracket accent for the scanning zone
struct ScanningCornerAccent: View {

    let isActive: Bool
    let activeColors: [Color]

    var body: some View {
        Path { path in
            let length: CGFloat = 30

            // Top-left corner shape
            path.move(to: CGPoint(x: 0, y: length))
            path.addLine(to: CGPoint(x: 0, y: 8))
            path.addQuadCurve(
                to: CGPoint(x: 8, y: 0),
                control: CGPoint(x: 0, y: 0)
            )
            path.addLine(to: CGPoint(x: length, y: 0))
        }
        .stroke(
            isActive
                ? LinearGradient(
                    colors: activeColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                : LinearGradient(
                    colors: [Color.white.opacity(0.6), Color.white.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
        )
        .shadow(
            color: isActive ? activeColors[0].opacity(0.6) : Color.clear,
            radius: 6
        )
    }
}

// MARK: - Scanning Zone Hint

/// Instructional text below the scanning zone
struct ScanningZoneHint: View {

    let targetName: String
    let isObjectDetected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isObjectDetected ? "checkmark.circle.fill" : "viewfinder")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(isObjectDetected ? Color(hex: "00FF94") : .white.opacity(0.8))

            Text(isObjectDetected ? "Hold steady..." : "Place \(targetName) here")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
        .animation(.easeInOut(duration: 0.2), value: isObjectDetected)
    }
}

// MARK: - Preview

#Preview("Scanning Zone - Inactive") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 40) {
            ScanningZoneView(
                progress: 0,
                isObjectDetected: false
            )
            .frame(height: 400)

            ScanningZoneHint(
                targetName: "Apple",
                isObjectDetected: false
            )
        }
    }
}

#Preview("Scanning Zone - Active") {
    ZStack {
        Color.black.ignoresSafeArea()

        VStack(spacing: 40) {
            ScanningZoneView(
                progress: 0.65,
                isObjectDetected: true
            )
            .frame(height: 400)

            ScanningZoneHint(
                targetName: "Apple",
                isObjectDetected: true
            )
        }
    }
}
