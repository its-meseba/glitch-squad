//
//  MissionBriefingView.swift
//  GlitchSquad
//
//  Shows the mission card and Pixel explaining the objective.
//  High-energy screen to get kids moving!
//

import SwiftUI

// MARK: - Mission Briefing View

/// The "launchpad" screen showing mission details before the hunt
struct MissionBriefingView: View {

    let mission: Mission
    @ObservedObject var audioService: AudioService
    let onAccept: () -> Void

    // Animation states
    @State private var cardScale: CGFloat = 0.8
    @State private var cardOpacity: Double = 0
    @State private var pixelOffset: CGFloat = 200
    @State private var showButton: Bool = false
    @State private var buttonPulse: Bool = false
    @State private var isSpeaking: Bool = false

    var body: some View {
        ZStack {
            // Background
            backgroundGradient

            // Content layout
            HStack(spacing: 0) {
                // Left side: Pixel character
                VStack {
                    Spacer()

                    PixelCharacterView(state: mission.pixelStateBefore, size: 140)
                        .offset(x: pixelOffset)

                    if isSpeaking {
                        // Speaking indicator
                        HStack(spacing: 4) {
                            ForEach(0..<3, id: \.self) { i in
                                Circle()
                                    .fill(Color(hex: "00D9FF"))
                                    .frame(width: 8, height: 8)
                                    .scaleEffect(isSpeaking ? 1.2 : 0.8)
                                    .animation(
                                        .easeInOut(duration: 0.4)
                                            .repeatForever()
                                            .delay(Double(i) * 0.15),
                                        value: isSpeaking
                                    )
                            }
                        }
                        .padding(.top, 8)
                        .offset(x: pixelOffset)
                    }

                    Spacer()
                }
                .frame(width: 180)

                // Right side: Mission card
                VStack(spacing: 24) {
                    Spacer()

                    // Mission card
                    missionCard
                        .scaleEffect(cardScale)
                        .opacity(cardOpacity)

                    // Accept button
                    if showButton {
                        acceptButton
                            .transition(.scale.combined(with: .opacity))
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.trailing, 40)
            }
        }
        .onAppear {
            startBriefingSequence()
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        ZStack {
            // Dark base
            Color(hex: "0D0D1A")
                .ignoresSafeArea()

            // Broken base background image
            Image("broken_base")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()
                .opacity(0.7)

            // Overlay gradient for depth
            LinearGradient(
                colors: [
                    Color.black.opacity(0.2),
                    Color.clear,
                    Color.black.opacity(0.4),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Subtle grid pattern
            GeometryReader { geo in
                Path { path in
                    let spacing: CGFloat = 40
                    for x in stride(from: 0, to: geo.size.width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    }
                    for y in stride(from: 0, to: geo.size.height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.03), lineWidth: 1)
            }
            .ignoresSafeArea()
        }
    }

    // MARK: - Mission Card

    private var missionCard: some View {
        VStack(spacing: 20) {
            // Mission title
            HStack {
                Image(systemName: "bolt.fill")
                    .foregroundStyle(Color(hex: "FFE066"))

                Text(mission.title.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.7))
            }

            // Fruit icon
            Text(mission.target.emoji)
                .font(.system(size: 80))
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

            // Mission prompt
            VStack(spacing: 8) {
                Text(mission.narrative)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.8))

                Text(mission.prompt)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 10)

            // Timer indicator
            HStack(spacing: 6) {
                Image(systemName: "timer")
                    .font(.system(size: 14))
                Text("60 seconds")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.6))
            .padding(.top, 8)
        }
        .padding(32)
        .background {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
    }

    // MARK: - Accept Button

    private var acceptButton: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()

            // Play sound
            audioService.playSound(.missionAccept)

            // Trigger callback
            onAccept()
        }) {
            HStack(spacing: 12) {
                Image(systemName: "rocket.fill")
                    .font(.system(size: 20, weight: .bold))

                Text("ACCEPT MISSION")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 40)
            .padding(.vertical, 18)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "00C853"),
                                Color(hex: "00E676"),
                                Color(hex: "69F0AE"),
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(buttonPulse ? 1.05 : 1.0)
            }
            .shadow(color: Color(hex: "00E676").opacity(0.5), radius: 15, x: 0, y: 8)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                buttonPulse = true
            }
        }
    }

    // MARK: - Briefing Sequence

    private func startBriefingSequence() {
        // Phase 1: Show card
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            cardScale = 1.0
            cardOpacity = 1.0
        }

        // Phase 2: Pixel slides in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7)) {
                pixelOffset = 0
            }
        }

        // Phase 3: Pixel speaks
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isSpeaking = true

            audioService.playMissionBriefing(mission) { [self] in
                isSpeaking = false

                // Show button after speaking
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showButton = true
                }
            }
        }

        // Fallback: Show button after 5 seconds if TTS doesn't work
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            if !showButton {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showButton = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Mission Briefing - Apple") {
    MissionBriefingView(
        mission: Mission.campaign[0],
        audioService: AudioService()
    ) {
        print("Mission accepted!")
    }
}

#Preview("Mission Briefing - Banana") {
    MissionBriefingView(
        mission: Mission.campaign[1],
        audioService: AudioService()
    ) {
        print("Mission accepted!")
    }
}
