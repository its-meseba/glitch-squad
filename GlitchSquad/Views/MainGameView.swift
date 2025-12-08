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

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Layer 1: Camera Background
                cameraLayer

                // Layer 2: Detection overlay (bounding boxes)
                if viewModel.gameState == .hunt || viewModel.gameState == .lockOn {
                    DetectionBoxOverlay(
                        detection: viewModel.currentDetection,
                        screenSize: geometry.size
                    )
                }

                // Layer 3: Game HUD overlay
                gameHUDLayer(in: geometry)

                // Layer 4: Lock-on UI
                if viewModel.gameState == .lockOn {
                    lockOnOverlay
                }
            }
        }
        .ignoresSafeArea()
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

    // MARK: - Game HUD Layer

    @ViewBuilder
    private func gameHUDLayer(in geometry: GeometryProxy) -> some View {
        VStack {
            // Top bar with timer and target
            topBar
                .padding(.top, geometry.safeAreaInsets.top + 20)

            Spacer()

            // Center reticle
            if viewModel.gameState == .hunt {
                reticle
            }

            Spacer()

            // Bottom hint
            bottomHint
                .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Target indicator
            HStack(spacing: 8) {
                Image(systemName: "viewfinder")
                    .font(.system(size: 16, weight: .semibold))

                Text("Find:")
                    .font(.system(size: 16, weight: .medium, design: .rounded))

                Text(viewModel.currentTarget.emoji)
                    .font(.system(size: 24))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: Capsule())

            Spacer()

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
