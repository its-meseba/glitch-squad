//
//  MissionCompleteView.swift
//  GlitchSquad
//
//  Success screen displayed after finding a target.
//  Matches the holographic aesthetic of MissionBriefingView.
//

import SwiftUI

struct MissionCompleteView: View {

    let mission: Mission
    let glitchBits: Int
    @ObservedObject var audioService: AudioService
    let onContinue: () -> Void

    @State private var showScripts: Bool = false
    @State private var showHologram: Bool = false
    @State private var isSpeaking: Bool = false
    @State private var currentSpeechText: String = ""

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.opacity(0.8).ignoresSafeArea()

                // Holographic grid background
                HolographicBackground()
                    .opacity(0.5)

                HStack(spacing: 0) {
                    // Left Side: 3D Object / Hologram (40%)
                    ZStack {
                        // Hologram base emitter
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color(hex: "00FF94").opacity(0.6), Color.clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 100
                                )
                            )
                            .rotation3DEffect(.degrees(70), axis: (x: 1, y: 0, z: 0))
                            .offset(y: 120)

                        // The collected item (hologram)
                        Text(mission.target.emoji)
                            .font(.system(size: 150))
                            .scaleEffect(showHologram ? 1.0 : 0.0)
                            .opacity(showHologram ? 1.0 : 0.0)
                            .shadow(color: Color(hex: "00FF94").opacity(0.8), radius: 20)
                            .overlay {
                                // Scanning grid effect over the item
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.clear, Color(hex: "00FF94").opacity(0.3),
                                                Color.clear,
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(height: 100)
                                    .offset(y: showHologram ? 200 : -200)
                                    .animation(
                                        .linear(duration: 2.0).repeatForever(autoreverses: false),
                                        value: showHologram
                                    )
                                    .mask(Text(mission.target.emoji).font(.system(size: 150)))
                            }
                    }
                    .frame(width: geometry.size.width * 0.4)

                    // Right Side: Mission Details (60%)
                    VStack(alignment: .leading, spacing: 20) {

                        // Header "MISSION COMPLETE"
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color(hex: "00FF94"))

                            Text("MISSION COMPLETE")
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundStyle(Color(hex: "00FF94"))
                                .tracking(2)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(hex: "00FF94").opacity(0.1))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "00FF94").opacity(0.3), lineWidth: 1)
                        )
                        .opacity(showScripts ? 1 : 0)
                        .offset(x: showScripts ? 0 : 50)

                        // Mission Title
                        Text(mission.title.uppercased())
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .shadow(color: Color(hex: "00FF94").opacity(0.5), radius: 10)
                            .opacity(showScripts ? 1 : 0)
                            .offset(x: showScripts ? 0 : 50)

                        // Reward Card
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "FFE066").opacity(0.2))
                                    .frame(width: 50, height: 50)

                                Image(systemName: "sparkles")
                                    .font(.system(size: 24))
                                    .foregroundStyle(Color(hex: "FFE066"))
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text("REWARD EARNED")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.white.opacity(0.6))

                                Text("+\(mission.rewardBits) GLITCH BITS")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color(hex: "FFE066"))
                            }
                        }
                        .padding(16)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "FFE066").opacity(0.3), lineWidth: 1)
                        )
                        .opacity(showScripts ? 1 : 0)
                        .offset(x: showScripts ? 0 : 50)

                        Spacer()

                        // "Return to Base" Button
                        Button(action: onContinue) {
                            HStack {
                                Text("RETURN TO BASE")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                Image(systemName: "arrow.right")
                            }
                            .foregroundStyle(.black)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(Color(hex: "00FF94"))
                            .clipShape(Capsule())
                            .shadow(color: Color(hex: "00FF94").opacity(0.5), radius: 15)
                        }
                        .opacity(showScripts ? 1 : 0)  // Initially hidden, could animate in later
                    }
                    .padding(.horizontal, 40)
                    .frame(width: geometry.size.width * 0.6)
                }
            }
        }
        // Pixel Dialog Overlay
        .pixelDialog(
            text: currentSpeechText,
            pixelState: .happy,
            isVisible: $isSpeaking,
            onComplete: nil  // User taps to dismiss, or it stays until they click button
        )
        .onAppear {
            animateIn()
        }
    }

    private func animateIn() {
        // 1. Hologram appears
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            showHologram = true
        }

        // 2. Text elements slide in
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            showScripts = true
        }

        // 3. Pixel speaks
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            currentSpeechText = mission.successLine
            isSpeaking = true  // Show dialog
            audioService.playSuccessSequence(
                successVoice: mission.successVoice,
                fallbackText: mission.successLine
            )
        }
    }
}

// MARK: - Preview
#Preview(traits: .landscapeLeft) {
    MissionCompleteView(
        mission: Mission.campaign[0],
        glitchBits: 100,
        audioService: AudioService(),
        onContinue: {}
    )
}
