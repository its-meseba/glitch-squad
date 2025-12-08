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
                IntroView(audioService: audioService) {
                    viewModel.completeIntro()
                }
                .transition(.opacity)

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
                SuccessView(
                    mission: viewModel.currentMission,
                    glitchBits: viewModel.glitchBits,
                    audioService: audioService
                ) {
                    viewModel.nextRound()
                }
                .transition(.scale.combined(with: .opacity))

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
        }
    }
}

// MARK: - Success View

/// Celebration screen after finding a fruit
struct SuccessView: View {

    let mission: Mission
    let glitchBits: Int
    @ObservedObject var audioService: AudioService
    let onContinue: () -> Void

    @State private var showContent: Bool = false
    @State private var pixelState: PixelState = .idle

    var body: some View {
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

            // Confetti
            ConfettiView()

            // Content
            VStack(spacing: 30) {
                // Pixel happy
                PixelCharacterView(state: .happy, size: 120)
                    .scaleEffect(showContent ? 1 : 0.5)
                    .opacity(showContent ? 1 : 0)

                // Success message
                VStack(spacing: 12) {
                    Text("MISSION COMPLETE!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text(mission.successLine)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .opacity(showContent ? 1 : 0)

                // Reward
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color(hex: "FFE066"))

                    Text("+\(mission.rewardBits) Glitch Bits")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(hex: "FFE066"))
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(.ultraThinMaterial, in: Capsule())
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)

                // Continue button
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
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
                        .shadow(color: Color(hex: "00D9FF").opacity(0.5), radius: 15)
                }
                .padding(.top, 20)
                .opacity(showContent ? 1 : 0)
            }
            .padding(40)
        }
        .onAppear {
            audioService.playSuccessSequence(successLine: mission.successLine)

            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
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
