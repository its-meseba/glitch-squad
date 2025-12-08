//
//  DigitizeView.swift
//  GlitchSquad
//
//  Capture animation when fruit is successfully detected.
//  Grid effect + shrink + fly to corner animation.
//

import SwiftUI

// MARK: - Digitize View

/// The "capture" animation after successfully finding a fruit
struct DigitizeView: View {

    let fruit: TargetFruit
    let onComplete: () -> Void

    // Animation states
    @State private var showGrid: Bool = false
    @State private var fruitScale: CGFloat = 1.0
    @State private var fruitOffset: CGSize = .zero
    @State private var fruitOpacity: Double = 1.0
    @State private var showScanLine: Bool = false
    @State private var scanLineOffset: CGFloat = -200
    @State private var particlesActive: Bool = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Dark overlay
                Color.black.opacity(0.6)
                    .ignoresSafeArea()

                // Grid effect
                if showGrid {
                    GridOverlay()
                        .transition(.opacity)
                }

                // Scan line
                if showScanLine {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    Color(hex: "00D9FF").opacity(0.8),
                                    Color.clear,
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 4)
                        .offset(y: scanLineOffset)
                        .blur(radius: 2)
                }

                // Fruit being captured
                VStack(spacing: 16) {
                    Text(fruit.emoji)
                        .font(.system(size: 100))

                    Text("TARGET ACQUIRED")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(hex: "00FF94"))
                        .tracking(3)
                }
                .scaleEffect(fruitScale)
                .offset(fruitOffset)
                .opacity(fruitOpacity)

                // Particles flying to corner
                if particlesActive {
                    ForEach(0..<15, id: \.self) { i in
                        DigitizeParticle(
                            color: Color(
                                hex: fruit.gradientColors[0].replacingOccurrences(of: "#", with: "")
                            ),
                            targetCorner: CGPoint(x: geometry.size.width - 50, y: 50),
                            delay: Double(i) * 0.05
                        )
                    }
                }

                // Destination indicator (top right)
                if fruitScale < 0.5 {
                    VStack {
                        HStack {
                            Spacer()

                            // Inventory slot
                            InventorySlot(fruit: fruit, isFilling: true)
                        }
                        .padding(.top, 60)
                        .padding(.trailing, 30)

                        Spacer()
                    }
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            startDigitizeSequence()
        }
    }

    // MARK: - Digitize Sequence

    private func startDigitizeSequence() {
        // Phase 1: Show grid (0s)
        withAnimation(.easeIn(duration: 0.3)) {
            showGrid = true
        }

        // Phase 2: Scan line passes (0.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            showScanLine = true
            withAnimation(.easeInOut(duration: 0.8)) {
                scanLineOffset = 200
            }
        }

        // Phase 3: Start particles (0.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            particlesActive = true
        }

        // Phase 4: Shrink and move fruit (0.8s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeInOut(duration: 0.6)) {
                fruitScale = 0.2
                fruitOffset = CGSize(width: 150, height: -250)
                fruitOpacity = 0
            }
        }

        // Phase 5: Complete (1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            onComplete()
        }
    }
}

// MARK: - Grid Overlay

/// Digital grid effect for scanning
struct GridOverlay: View {

    @State private var lineOpacity: Double = 0.3

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Horizontal lines
                VStack(spacing: 20) {
                    ForEach(0..<30, id: \.self) { _ in
                        Rectangle()
                            .fill(Color(hex: "00D9FF").opacity(lineOpacity))
                            .frame(height: 1)
                    }
                }

                // Vertical lines
                HStack(spacing: 20) {
                    ForEach(0..<40, id: \.self) { _ in
                        Rectangle()
                            .fill(Color(hex: "00D9FF").opacity(lineOpacity))
                            .frame(width: 1)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true)) {
                lineOpacity = 0.6
            }
        }
    }
}

// MARK: - Digitize Particle

/// Single particle that flies toward the inventory slot
struct DigitizeParticle: View {

    let color: Color
    let targetCorner: CGPoint
    let delay: Double

    @State private var position: CGPoint = .zero
    @State private var opacity: Double = 1.0
    @State private var hasStarted: Bool = false

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 8, height: 8)
            .shadow(color: color, radius: 4)
            .opacity(opacity)
            .position(position)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    // Start from center-ish with some randomness
                    position = CGPoint(
                        x: UIScreen.main.bounds.width / 2 + CGFloat.random(in: -50...50),
                        y: UIScreen.main.bounds.height / 2 + CGFloat.random(in: -50...50)
                    )
                    hasStarted = true

                    withAnimation(.easeIn(duration: 0.6)) {
                        position = targetCorner
                        opacity = 0
                    }
                }
            }
    }
}

// MARK: - Inventory Slot

/// Visual slot where captured items go
struct InventorySlot: View {

    let fruit: TargetFruit
    let isFilling: Bool

    @State private var glowOpacity: Double = 0.5

    var body: some View {
        ZStack {
            // Slot background
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .frame(width: 60, height: 60)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            Color(hex: "00D9FF").opacity(glowOpacity),
                            lineWidth: 2
                        )
                }

            // Fruit icon (small)
            if isFilling {
                Text(fruit.emoji)
                    .font(.system(size: 30))
                    .scaleEffect(isFilling ? 1 : 0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isFilling)
            }
        }
        .shadow(color: Color(hex: "00D9FF").opacity(0.5), radius: 10)
        .onAppear {
            if isFilling {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    glowOpacity = 1.0
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Digitize View") {
    DigitizeView(fruit: .apple) {
        print("Digitize complete!")
    }
}
