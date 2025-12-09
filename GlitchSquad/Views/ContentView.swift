//
//  ContentView.swift
//  GlitchSquad
//
//  Main router view that switches between game states.
//  Entry point for the Glitch Squad experience.
//

import SwiftUI

// MARK: - Content View (Router)

/// Routes to the appropriate view based on game state
struct ContentView: View {

    @StateObject private var viewModel = GameViewModel()
    @StateObject private var audioService = AudioService()

    var body: some View {
        ZStack {
            switch viewModel.gameState {
            case .intro:
                OnboardingView {
                    viewModel.completeIntro()
                }
                .transition(.opacity)

            case .base:
                BaseView(
                    viewModel: viewModel,
                    audioService: audioService,
                    onStartMission: {
                        viewModel.goToMissionBriefing()
                    },
                    onOpenCollection: {
                        viewModel.goToCollection()
                    }
                )
                .transition(.opacity)

            case .collection:
                CollectionView(
                    progress: viewModel.progress,
                    onDismiss: {
                        viewModel.goToBase()
                    }
                )
                .transition(.move(edge: .trailing).combined(with: .opacity))

            case .missionBriefing:
                MissionBriefingView(
                    mission: viewModel.currentMission,
                    audioService: audioService
                ) {
                    viewModel.startHunt()
                }
                .transition(
                    .asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))

            case .goal, .hunt, .lockOn:
                MainGameView(
                    viewModel: viewModel,
                    audioService: audioService
                )
                .transition(.opacity)

            case .digitizing:
                DigitizeView(fruit: viewModel.currentTarget) {
                    viewModel.completeDigitize()
                }
                .transition(.opacity)

            case .success:
                MissionCompleteView(
                    mission: viewModel.currentMission,
                    glitchBits: viewModel.glitchBits,
                    audioService: audioService
                ) {
                    viewModel.nextRound()
                }
                .transition(.opacity)  // Smoother transition for full screen success

            case .gameOver:
                GameCompleteView(
                    totalBits: viewModel.glitchBits,
                    audioService: audioService
                ) {
                    viewModel.resetGame()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.gameState)
        .task {
            await viewModel.onAppear()
            // Clear notification badge on app open
            ParentNotificationService.shared.clearBadge()
        }
    }
}

// MARK: - Game Complete View

/// Final screen when all missions are done
struct GameCompleteView: View {

    let totalBits: Int
    @ObservedObject var audioService: AudioService
    let onRestart: () -> Void

    @State private var showContent: Bool = false

    var body: some View {
        ZStack {
            // Background - repaired (cleaner gradient)
            LinearGradient(
                colors: [
                    Color(hex: "1A1A3E"),
                    Color(hex: "2A2A5E"),
                    Color(hex: "3A3A7E"),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Stars/sparkles
            ConfettiView()

            VStack(spacing: 32) {
                // Trophy
                Text("🏆")
                    .font(.system(size: 100))
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                // Pixel fully repaired
                PixelCharacterView(state: .happy, size: 150)
                    .opacity(showContent ? 1 : 0)

                // Message
                VStack(spacing: 12) {
                    Text("PIXEL REPAIRED!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("You're the best repair crew in the galaxy!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)

                // Total bits earned
                VStack(spacing: 8) {
                    Text("Total Earned")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))

                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                        Text("\(totalBits) Glitch Bits")
                    }
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(hex: "FFE066"))
                }
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .opacity(showContent ? 1 : 0)

                // Play again
                Button(action: onRestart) {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Play Again")
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 18)
                    .background {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    .shadow(color: Color(hex: "8B5CF6").opacity(0.5), radius: 15)
                }
                .padding(.top, 16)
                .opacity(showContent ? 1 : 0)
            }
            .padding(40)
        }
        .onAppear {
            audioService.speak(
                "You did it! All systems restored! Thank you, Agent. You're the best repair crew in the galaxy!",
                completion: nil)

            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                showContent = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
