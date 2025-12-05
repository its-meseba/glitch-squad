//
//  MainGameView.swift
//  FruitPeek
//
//  Main game screen integrating camera, detection UI, and game states.
//  Uses matchedGeometryEffect for smooth transitions between states.
//

import SwiftUI

// MARK: - Main Game View

/// The primary game screen orchestrating all game states and UI layers.
/// Camera runs in the background with glass UI overlays.
struct MainGameView: View {

    @StateObject private var viewModel = GameViewModel()
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

                // Layer 3: Game UI overlay
                gameUILayer(in: geometry)

                // Layer 4: Success celebration
                if viewModel.gameState == .success {
                    SuccessOverlay(fruit: viewModel.currentTarget)
                        .transition(.opacity.combined(with: .scale))
                }

                // Layer 5: Game Over screen
                if viewModel.gameState == .gameOver {
                    GameOverView(
                        score: viewModel.score,
                        total: viewModel.totalFruits,
                        onRestart: {
                            viewModel.resetGame()
                        }
                    )
                    .transition(.opacity)
                }
            }
        }
        .ignoresSafeArea()
        .task {
            await viewModel.onAppear()
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

                    Text("FruitPeek needs camera access to find fruits!")
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

    // MARK: - Game UI Layer

    @ViewBuilder
    private func gameUILayer(in geometry: GeometryProxy) -> some View {
        VStack {
            // Top bar with timer and score
            if viewModel.gameState == .hunt || viewModel.gameState == .lockOn {
                topBar
                    .padding(.top, geometry.safeAreaInsets.top + 20)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            Spacer()

            // Center content based on state
            centerContent(in: geometry)

            Spacer()

            // Bottom hint
            if viewModel.gameState == .hunt {
                bottomHint
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.gameState)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            TimerDisplay(timeRemaining: viewModel.timeRemaining)

            Spacer()

            ScoreDisplay(score: viewModel.score, total: viewModel.totalFruits)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Center Content

    @ViewBuilder
    private func centerContent(in geometry: GeometryProxy) -> some View {
        switch viewModel.gameState {
        case .goal:
            goalStateContent

        case .hunt:
            huntStateContent

        case .lockOn:
            lockOnStateContent

        case .success, .gameOver:
            // Handled by overlay layers
            EmptyView()
        }
    }

    // MARK: - Goal State

    private var goalStateContent: some View {
        VStack(spacing: 32) {
            // Fruit card with matched geometry
            FruitCard(fruit: viewModel.currentTarget)
                .matchedGeometryEffect(id: "fruitCard", in: animation)

            // Ready button
            ReadyButton {
                viewModel.startHunt()
            }
        }
        .padding(.horizontal, 40)
    }

    // MARK: - Hunt State

    private var huntStateContent: some View {
        VStack(spacing: 20) {
            // Compact fruit indicator
            FruitCard(fruit: viewModel.currentTarget, isCompact: true)
                .matchedGeometryEffect(id: "fruitCard", in: animation)
                .scaleEffect(0.6)
        }
    }

    // MARK: - Lock-On State

    private var lockOnStateContent: some View {
        VStack(spacing: 24) {
            // Compact fruit indicator
            FruitCard(fruit: viewModel.currentTarget, isCompact: true)
                .scaleEffect(0.5)

            // Lock-on ring
            LockOnRing(progress: viewModel.lockOnProgress)
                .transition(.scale.combined(with: .opacity))

            Text("Hold steady...")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.9))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: Capsule())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    // MARK: - Bottom Hint

    private var bottomHint: some View {
        HStack(spacing: 8) {
            Image(systemName: "viewfinder")
                .font(.system(size: 14, weight: .medium))

            Text("Point camera at \(viewModel.currentTarget.emoji)")
                .font(.system(size: 14, weight: .medium, design: .rounded))
        }
        .foregroundStyle(.white.opacity(0.8))
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial, in: Capsule())
    }
}

// MARK: - Preview

#Preview("Goal State") {
    MainGameView()
}
