//
//  BaseView.swift
//  GlitchSquad
//
//  The home screen showing Pixel's base/island that evolves
//  as missions are completed. Entry point after intro.
//

import SwiftUI

// MARK: - Base View (Home Screen)

/// The central hub showing the evolving base island
struct BaseView: View {

    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var audioService: AudioService
    let onStartMission: () -> Void
    let onOpenCollection: () -> Void

    @State private var islandScale: CGFloat = 0.8
    @State private var islandOffset: CGFloat = 50
    @State private var showUI: Bool = false
    @State private var glowPulse: Bool = false
    @State private var showParentDashboard: Bool = false
    @State private var showSleepingView: Bool = false
    @StateObject private var networkMonitor = NetworkMonitor()

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient

            // Floating particles
            FloatingParticlesView()

            // Main content
            VStack(spacing: 0) {
                // Top bar with title and collection button
                topBar
                    .opacity(showUI ? 1 : 0)

                Spacer()

                // Isometric island
                islandView
                    .scaleEffect(islandScale)
                    .offset(y: islandOffset)

                Spacer()

                // Energy bar and mission button
                bottomSection
                    .opacity(showUI ? 1 : 0)
            }
            .padding()
        }
        .onAppear {
            animateIn()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "0D0D1A"),
                Color(hex: "1A1A2E"),
                Color(hex: "16213E"),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Parent dashboard button (long press)
            Button(action: {}) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("GLITCH SQUAD")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Eco Dome: \(viewModel.progress.baseStage.title)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .onLongPressGesture(minimumDuration: 1.5) {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                showParentDashboard = true
            }

            Spacer()

            // Offline indicator (prominent privacy badge)
            if !networkMonitor.isConnected {
                HStack(spacing: 6) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 12))
                    Text("Offline")
                }
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(hex: "00FF94"))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial, in: Capsule())
            }

            // Energy meter (daily missions remaining)
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            i < viewModel.dailyProgress.missionsRemaining
                                ? Color(hex: "00FF94")
                                : Color.white.opacity(0.2)
                        )
                        .frame(width: 8, height: 16)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())

            // Collection button
            Button(action: onOpenCollection) {
                HStack(spacing: 8) {
                    Image(systemName: "square.grid.2x2")
                    Text(
                        "\(viewModel.progress.collectedItems.count)/\(CollectableItem.allItems.count)"
                    )
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: Capsule())
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }

    // MARK: - Island View

    private var islandView: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            stageGlowColor.opacity(0.3),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .scaleEffect(glowPulse ? 1.1 : 1.0)
                .blur(radius: 30)

            // Island image
            Image(viewModel.progress.baseStage.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 350)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)

            // Pixel on the island
            PixelCharacterView(state: pixelStateForBase, size: 80)
                .offset(y: -20)
        }
    }

    private var stageGlowColor: Color {
        switch viewModel.progress.baseStage {
        case .broken: return Color(hex: "FF6B6B")
        case .stabilizing: return Color(hex: "FFE066")
        case .growing: return Color(hex: "00FF94")
        case .restored: return Color(hex: "00D9FF")
        }
    }

    private var pixelStateForBase: PixelState {
        switch viewModel.progress.baseStage {
        case .broken: return .sad
        case .stabilizing: return .idle
        case .growing: return .idle
        case .restored: return .happy
        }
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        VStack(spacing: 20) {
            // Energy bar
            energyBar

            // Mission button, energy depleted, or complete message
            if viewModel.progress.currentMissionIndex >= Mission.campaign.count {
                allCompleteMessage
            } else if !viewModel.dailyProgress.canPlay {
                energyDepletedButton
            } else {
                missionButton
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
        .fullScreenCover(isPresented: $showParentDashboard) {
            ParentDashboardView(
                isPresented: $showParentDashboard,
                viewModel: viewModel
            )
        }
        .fullScreenCover(isPresented: $showSleepingView) {
            PixelSleepingView(
                dailyProgress: viewModel.dailyProgress,
                onParentOverride: {
                    var progress = viewModel.dailyProgress
                    progress.grantBonusMission()
                    viewModel.updateDailyProgress(progress)
                    showSleepingView = false
                }
            )
        }
    }

    private var energyBar: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color(hex: "FFE066"))
                Text("Energy Level")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                Text("\(Int(viewModel.progress.batteryPercentage))%")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)

                    // Fill
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "00D9FF"), Color(hex: "00FF94")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * viewModel.progress.batteryPercentage / 100)
                }
            }
            .frame(height: 12)
        }
        .padding(16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var missionButton: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            onStartMission()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))

                VStack(alignment: .leading, spacing: 2) {
                    Text("MISSION AVAILABLE")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text(viewModel.currentMission.title)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .opacity(0.8)
                }

                Spacer()

                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color(hex: "FF6B6B"), Color(hex: "F472B6")],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .shadow(color: Color(hex: "FF6B6B").opacity(0.4), radius: 15, x: 0, y: 8)
        }
    }

    private var energyDepletedButton: some View {
        Button(action: {
            showSleepingView = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "moon.zzz.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: "FFE066"))

                VStack(alignment: .leading, spacing: 2) {
                    Text("PIXEL IS RESTING")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                    Text("Energy refills in \(viewModel.dailyProgress.timeUntilResetFormatted)")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .opacity(0.8)
                }

                Spacer()

                Image(systemName: "chevron.right")
            }
            .foregroundStyle(.white)
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
    }

    private var allCompleteMessage: some View {
        VStack(spacing: 12) {
            Text("🎉 All Missions Complete!")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Pixel is fully restored!")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Animation

    private func animateIn() {
        // Island entrance
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
            islandScale = 1.0
            islandOffset = 0
        }

        // UI fade in
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            showUI = true
        }

        // Glow pulse
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(1.0)) {
            glowPulse = true
        }
    }
}

// MARK: - Floating Particles

struct FloatingParticlesView: View {

    @State private var particles: [Particle] = []

    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var size: CGFloat
        var opacity: Double
        var speed: Double
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(Color.white)
                        .frame(width: particle.size, height: particle.size)
                        .opacity(particle.opacity)
                        .position(x: particle.x, y: particle.y)
                }
            }
            .onAppear {
                generateParticles(in: geo.size)
            }
        }
        .ignoresSafeArea()
    }

    private func generateParticles(in size: CGSize) {
        particles = (0..<20).map { _ in
            Particle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 2...6),
                opacity: Double.random(in: 0.1...0.3),
                speed: Double.random(in: 1...3)
            )
        }
    }
}

// MARK: - Preview

#Preview("Base View - Broken") {
    BaseView(
        viewModel: GameViewModel(),
        audioService: AudioService(),
        onStartMission: {},
        onOpenCollection: {}
    )
}
