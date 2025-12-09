//
//  MainGameView.swift
//  GlitchSquad
//
//  Camera hunt view with detection overlay and HUD.
//  Used during the hunt and lock-on phases.
//

import SwiftUI

// MARK: - Main Game View

/// The camera hunt screen with detection overlay and glass HUD
struct MainGameView: View {

    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var audioService: AudioService
    @Namespace private var animation
    @State private var showParentOverride: Bool = false
    @State private var huntStartTime: Date = Date()

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: Camera Background
                cameraLayer

                // Layer 2: Detection overlay (bounding boxes)
                // Only show when object is detected (inside or outside zone)
                if viewModel.gameState == .hunt || viewModel.gameState == .lockOn {
                    DetectionBoxOverlay(
                        detection: viewModel.currentDetection,
                        screenSize: geometry.size,
                        scanningZoneRect: viewModel.scanningZoneRect,
                        isInZone: viewModel.isObjectInZone
                    )
                }

                // Layer 3: Scanning Zone (center frame)
                if viewModel.gameState == .hunt || viewModel.gameState == .lockOn {
                    ScanningZoneView(
                        progress: viewModel.lockOnProgress,
                        isObjectDetected: viewModel.isObjectInZone
                    )
                }

                // Layer 4: Game HUD overlay
                gameHUDLayer(in: geometry)

                // Layer 5: Privacy Badge (top-right)
                VStack {
                    HStack {
                        Spacer()
                        PrivacyBadge()
                            .padding(.top, geometry.safeAreaInsets.top + 60)
                            .padding(.trailing, 16)
                    }
                    Spacer()

                    // Parent Override Button (shows after 30s of no success)
                    if showParentOverride {
                        parentOverrideButton
                            .padding(.bottom, geometry.safeAreaInsets.bottom + 100)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .onAppear {
                viewModel.updateScreenGeometry(size: geometry.size)
            }
            .onChange(of: geometry.size) { newSize in
                viewModel.updateScreenGeometry(size: newSize)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            huntStartTime = Date()
            showParentOverride = false
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            // Show parent override after 30 seconds of hunting
            if viewModel.gameState == .hunt,
                Date().timeIntervalSince(huntStartTime) > 30,
                !showParentOverride
            {
                withAnimation {
                    showParentOverride = true
                }
            }
        }
    }

    // MARK: - Parent Override

    private var parentOverrideButton: some View {
        Button(action: {}) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle")
                Text("Need Help?")
            }
            .font(.system(size: 14, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.7))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())
        }
        .onLongPressGesture(minimumDuration: 2.0) {
            // Parent override - force complete the mission
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            // Log the override
            viewModel.activityLog.log(.parentOverride, details: viewModel.currentMission.title)

            // Complete with partial reward
            viewModel.forceCompleteMission()
        }
    }

    // MARK: - Camera Layer

    @ViewBuilder
    private var cameraLayer: some View {
        if viewModel.isCameraAuthorized {
            CameraPreviewView(session: viewModel.cameraService.captureSession)
                .ignoresSafeArea()
        } else {
            // Permission denied or not yet requested
            permissionView
        }
    }

    // MARK: - Permission View

    private var permissionView: some View {
        ZStack {
            // Background
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

            GlassCard {
                VStack(spacing: 24) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.white.opacity(0.8))

                    Text("Camera Access Needed")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Glitch Squad needs camera access to help Pixel find items!")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)

                    Button(action: {
                        // Open Settings
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }) {
                        Text("Open Settings")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 14)
                            .background {
                                Capsule()
                                    .fill(Color(hex: "6366F1"))
                            }
                    }
                }
            }
            .padding(.horizontal, 40)
        }
    }

    @ViewBuilder
    private func gameHUDLayer(in geometry: GeometryProxy) -> some View {
        ZStack {
            // Top Center: Large Target Display
            VStack {
                targetDisplay
                    .padding(.top, geometry.safeAreaInsets.top + 20)
                Spacer()
            }

            // Top Left/Right: Timer and Score
            VStack {
                topBar
                    .padding(.top, geometry.safeAreaInsets.top + 12)
                Spacer()
            }

            // Bottom: Scanning zone hint + instructions
            VStack(spacing: 16) {
                Spacer()

                if viewModel.gameState == .lockOn {
                    Text("TARGET ACQUIRED! HOLD STEADY...")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(hex: "00FF94"))
                        .tracking(1)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .transition(.scale.combined(with: .opacity))
                }

                ScanningZoneHint(
                    targetName: viewModel.currentTarget.displayName,
                    isObjectDetected: viewModel.isObjectInZone
                )
            }
            .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
        }
        .animation(.easeInOut(duration: 0.2), value: viewModel.gameState)
        // Audio Feedback Triggers
        .onChange(of: viewModel.gameState) { newState in
            if newState == .lockOn {
                // Play lock-on start sound
                audioService.playSound(.targetLock)
            } else if newState == .success {
                // Play success sound
                audioService.playSound(.successPowerup)
            }
        }
        // Continuous feedback during lock-on
        .onChange(of: viewModel.lockOnProgress) { progress in
            if progress > 0.1 && viewModel.gameState == .lockOn {
                // Play ticking sound based on progress steps
                let step = Int(progress * 10)
                if step > Int((progress - 0.02) * 10) {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
        }
    }

    // MARK: - Target Display

    private var targetDisplay: some View {
        HStack(spacing: 16) {
            // Large emoji
            Text(viewModel.currentTarget.emoji)
                .font(.system(size: 50))

            VStack(alignment: .leading, spacing: 4) {
                Text("FIND")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(2)

                Text(viewModel.currentTarget.displayName.uppercased())
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Timer
            TimerDisplay(timeRemaining: viewModel.timeRemaining)

            Spacer()

            // Score / Glitch Bits
            GlitchBitsDisplay(bits: viewModel.glitchBits)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Reticle

    private var reticle: some View {
        ZStack {
            // Corner brackets
            ForEach(0..<4, id: \.self) { corner in
                ReticleCorner()
                    .rotationEffect(.degrees(Double(corner) * 90))
            }
        }
        .frame(width: 200, height: 200)
    }

    // MARK: - Lock-On Overlay

    private var lockOnOverlay: some View {
        VStack(spacing: 24) {
            // Lock-on ring
            LockOnRing(progress: viewModel.lockOnProgress)
                .transition(.scale.combined(with: .opacity))

            Text("TARGET ACQUIRED! HOLD STEADY...")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(hex: "00FF94"))
                .tracking(1)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Bottom Hint

    private var bottomHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 14, weight: .medium))

            Text(
                "Point camera at \(viewModel.currentTarget.emoji) \(viewModel.currentTarget.displayName)"
            )
            .font(.system(size: 14, weight: .medium, design: .rounded))
        }
        .foregroundStyle(.white.opacity(0.8))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

// MARK: - Reticle Corner

/// Corner bracket for the targeting reticle
struct ReticleCorner: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 30))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 30, y: 0))
        }
        .stroke(Color.white.opacity(0.8), lineWidth: 3)
        .offset(x: -100, y: -100)
    }
}

// MARK: - Glitch Bits Display

/// Shows current Glitch Bits (coins) earned
struct GlitchBitsDisplay: View {

    let bits: Int

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .foregroundStyle(Color(hex: "FFE066"))

            Text("\(bits)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

// MARK: - Preview

#Preview("Hunt State") {
    MainGameView(
        viewModel: GameViewModel.preview(state: .hunt),
        audioService: AudioService()
    )
}
