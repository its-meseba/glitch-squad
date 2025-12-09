//
//  BaseView.swift
//  GlitchSquad
//
//  The home screen showing Pixel's base/island that evolves
//  as missions are completed. Optimized for horizontal/landscape.
//

import SwiftUI

// MARK: - Base View (Home Screen)

/// The central hub showing the evolving base island
/// Redesigned for iPad/iPhone horizontal (landscape) orientation
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
    @State private var hasPlayedIntroVoice: Bool = false
    @State private var showMissionPrompt: Bool = false
    @State private var isSpeaking: Bool = false
    @State private var currentSpeechText: String = ""
    @StateObject private var networkMonitor = NetworkMonitor()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                backgroundGradient

                // Floating particles
                FloatingParticlesView()

                // Main horizontal layout
                HStack(spacing: 0) {
                    // Left side - Island and Pixel (65%)
                    islandSection
                        .frame(width: geometry.size.width * 0.65)

                    // Right side - Control panel (35%)
                    controlPanel
                        .frame(width: geometry.size.width * 0.35)
                        .opacity(showUI ? 1 : 0)
                }

                // Top bar overlay
                VStack {
                    gameNavBar
                        .opacity(showUI ? 1 : 0)
                    Spacer()
                }

                // Bottom Left Reset Button
                VStack {
                    Spacer()
                    HStack {
                        resetButton
                            .opacity(showUI ? 1 : 0)
                        Spacer()
                    }
                }
            }
        }
        .ignoresSafeArea()
        .onAppear {
            animateIn()
            playIntroVoiceIfNeeded()
        }
        .pixelDialog(
            text: currentSpeechText,
            pixelState: pixelStateForBase,
            isVisible: $isSpeaking,
            onComplete: nil,
            onDismiss: {
                audioService.stopSpeaking()
            }
        )
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
        .overlay {
            if showResetting {
                ZStack {
                    Color.black.ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.5)
                        Text("SYSTEM RESTORE INITIATED...")
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
    }

    @State private var showResetting: Bool = false

    // MARK: - Voice Introduction

    private func playIntroVoiceIfNeeded() {
        guard !hasPlayedIntroVoice else { return }
        hasPlayedIntroVoice = true

        // Delay slightly to let UI settle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
            // Determine text based on progress
            let itemsFound = viewModel.progress.collectedItems.count
            switch itemsFound {
            case 0: currentSpeechText = VoiceScript.introGreeting
            case 1:
                currentSpeechText =
                    "Wonderful! I am getting better and you're saving my world! Now you need to find a BANANA!"
            case 2:
                currentSpeechText =
                    "Spectacular! Systems are at 70 percent! Just one more to go. Find me an ORANGE!"
            case 3: currentSpeechText = "Thank you for today! See you later for our next mission!"
            default: currentSpeechText = "Thank you for today! See you later for our next mission!"
            }

            isSpeaking = true

            // Play voice
            audioService.playProgressUpdate(itemsFound: itemsFound) {
                // Hide speech bubble after voice completes
                DispatchQueue.main.async {
                    isSpeaking = false

                    // Show mission prompt if missions remain
                    if viewModel.canStartMission {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            showMissionPrompt = true
                        }
                    }
                }
            }
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
    }

    // MARK: - Game Navigation Bar

    private var gameNavBar: some View {
        HStack(spacing: 16) {
            // Left section - Energy & Daily Activity
            energyAndActivitySection

            Spacer()

            // Right section - Status badges
            HStack(spacing: 10) {
                // Offline indicator
                if !networkMonitor.isConnected {
                    StatusBadge(
                        icon: "lock.shield.fill",
                        text: "Private",
                        color: Color(hex: "00FF94")
                    )
                }

                // Glitch Bits counter
                StatusBadge(
                    icon: "sparkles",
                    text: "\(viewModel.glitchBits)",
                    color: Color(hex: "FFE066")
                )

                // Collection button (Top Right with Text)
                Button(action: onOpenCollection) {
                    HStack(spacing: 8) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.system(size: 14))

                        Text("Collection")
                            .font(.system(size: 12, weight: .semibold, design: .rounded))

                        Text(
                            "\(viewModel.progress.collectedItems.count)/\(CollectableItem.allItems.count)"
                        )
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .opacity(0.8)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(hex: "00D9FF").opacity(0.8), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Energy & Activity Section

    private var energyAndActivitySection: some View {
        HStack(spacing: 16) {
            // Title with long press for parent dashboard
            Button(action: {}) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("GLITCH SQUAD")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(viewModel.progress.baseStage.title)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .onLongPressGesture(minimumDuration: 1.5) {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                showParentDashboard = true
            }

            // Divider
            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(width: 1, height: 32)

            // Energy display
            HStack(spacing: 12) {
                // Energy icon and bars
                HStack(spacing: 6) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(hex: "FFE066"))

                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    i < viewModel.dailyProgress.missionsRemaining
                                        ? LinearGradient(
                                            colors: [Color(hex: "00FF94"), Color(hex: "00D9FF")],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                        : LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.15), Color.white.opacity(0.1),
                                            ],
                                            startPoint: .bottom,
                                            endPoint: .top
                                        )
                                )
                                .frame(width: 8, height: 18)
                        }
                    }
                }

                // Daily stats
                VStack(alignment: .leading, spacing: 1) {
                    Text("Today")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))

                    Text("\(viewModel.dailyProgress.missionsToday) missions")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Island Section (Left 65%)

    private var islandSection: some View {
        ZStack {
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            stageGlowColor.opacity(0.4),
                            Color.clear,
                        ],
                        center: .center,
                        startRadius: 30,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .scaleEffect(glowPulse ? 1.15 : 1.0)
                .blur(radius: 40)

            // Island image
            Image(viewModel.progress.baseStage.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: 320, maxHeight: 280)
                .shadow(color: .black.opacity(0.4), radius: 30, x: 0, y: 15)
                .scaleEffect(islandScale)
                .offset(y: islandOffset)

            // Pixel character (no speech bubble - using dialog overlay instead)
            PixelCharacterView(state: pixelStateForBase, size: 70)
                .offset(y: islandOffset - 30)
                .scaleEffect(islandScale)
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

    // MARK: - Control Panel (Right 35%)

    private var controlPanel: some View {
        VStack(spacing: 16) {
            Spacer()

            // Mission or status button
            if viewModel.progress.currentMissionIndex >= Mission.campaign.count {
                allCompleteCard
            } else if !viewModel.dailyProgress.canPlay {
                energyDepletedCard
            } else {
                missionCard
                    .padding(.vertical, 20)  // Extra padding to make it visually bigger
            }

            // Collection button removed from bottom

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
    }

    private var resetButton: some View {
        Button(action: {
            withAnimation { showResetting = true }

            // Simulate system restore delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                viewModel.fullDebugReset()
                // Resetting state will be cleared when View reloads/state changes
                showResetting = false
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                Text("Reset the user data")
            }
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundStyle(.white.opacity(0.4))
            .padding(12)
            .background(.ultraThinMaterial.opacity(0.5), in: Capsule())
        }
        .padding(.leading, 32)
        .padding(.bottom, 24)
    }

    // MARK: - Mission Card

    private var missionCard: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            onStartMission()
        }) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color(hex: "FF6B6B"))

                    Text("MISSION AVAILABLE")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))

                    Spacer()

                    // Pulsing indicator
                    Circle()
                        .fill(Color(hex: "FF6B6B"))
                        .frame(width: 10, height: 10)
                        .scaleEffect(showMissionPrompt ? 1.3 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: showMissionPrompt
                        )
                }

                Spacer().frame(height: 4)

                // Mission title (Larger)
                Text(viewModel.currentMission.title)
                    .font(.system(size: 24, weight: .black, design: .rounded))  // Bigger font
                    .foregroundStyle(.white)

                // Target fruit with background
                HStack(spacing: 12) {
                    Text(viewModel.currentTarget.emoji)
                        .font(.system(size: 32))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("TARGET")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))

                        Text(viewModel.currentTarget.displayName)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }

                    Spacer()

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                        .shadow(radius: 5)
                }
                .padding(12)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(24)  // Increased padding
            .frame(maxWidth: .infinity)  // Fill width
            .background(
                LinearGradient(
                    colors: [Color(hex: "FF6B6B").opacity(0.9), Color(hex: "F472B6").opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 24)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
            )
        }
        .shadow(color: Color(hex: "FF6B6B").opacity(0.4), radius: 20, x: 0, y: 10)
    }

    // MARK: - Energy Depleted Card

    private var energyDepletedCard: some View {
        Button(action: {
            showSleepingView = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Color(hex: "FFE066"))

                    Text("RESTING")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))

                    Spacer()
                }

                Text("Pixel is Sleeping")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                HStack {
                    Text("Energy refills in")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))

                    Text(viewModel.dailyProgress.timeUntilResetFormatted)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "00D9FF"))
                }
            }
            .padding(20)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        }
    }

    // MARK: - All Complete Card

    private var allCompleteCard: some View {
        VStack(spacing: 12) {
            Text("🎉")
                .font(.system(size: 40))

            Text("All Missions Complete!")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Pixel is fully restored")
                .font(.system(size: 13, weight: .medium, design: .rounded))
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

// MARK: - Status Badge Component

struct StatusBadge: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundStyle(color)

            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
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
    }

    private func generateParticles(in size: CGSize) {
        particles = (0..<25).map { _ in
            Particle(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height),
                size: CGFloat.random(in: 1...4),
                opacity: Double.random(in: 0.1...0.25),
                speed: Double.random(in: 1...3)
            )
        }
    }
}

// MARK: - Preview

#Preview("Base View - Horizontal") {
    BaseView(
        viewModel: GameViewModel(),
        audioService: AudioService(),
        onStartMission: {},
        onOpenCollection: {}
    )
    .previewInterfaceOrientation(.landscapeLeft)
}
