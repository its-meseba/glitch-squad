//
//  MissionBriefingView.swift
//  GlitchSquad
//
//  Shows the mission "Incoming Transmission" screen.
//  Immersive holographic command center style.
//

import SwiftUI

// MARK: - Mission Briefing View

/// The "launchpad" screen showing mission details before the hunt
struct MissionBriefingView: View {

    let mission: Mission
    @ObservedObject var audioService: AudioService
    let onAccept: () -> Void

    // Animation states
    @State private var showContent: Bool = false
    @State private var scaleEffect: CGFloat = 0.5
    @State private var rotation: Double = 0
    @State private var warningOpacity: Double = 0
    @State private var isSpeaking: Bool = false

    var body: some View {
        ZStack {
            // Background
            backgroundLayer

            // Main Content
            VStack(spacing: 0) {
                // Top Header: Warning Tape
                headerView
                    .opacity(showContent ? 1 : 0)
                    .offset(y: showContent ? 0 : -50)

                HStack(spacing: 0) {
                    // Left: Holographic Target Visualization (Hero)
                    ZStack {
                        // Grid floor
                        gridFloor

                        // Target Fruit Hologram
                        Text(mission.target.emoji)
                            .font(.system(size: 140))
                            .shadow(color: themeColor.opacity(0.8), radius: 30, x: 0, y: 0)
                            .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                            .scaleEffect(scaleEffect)
                            .rotation3DEffect(.degrees(rotation), axis: (x: 0, y: 1, z: 0))
                            .onAppear {
                                withAnimation(
                                    .linear(duration: 8).repeatForever(autoreverses: false)
                                ) {
                                    rotation = 360
                                }
                            }

                        // Scanning Rings
                        ForEach(0..<2) { i in
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        colors: [themeColor, .clear],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: 2
                                )
                                .rotation3DEffect(.degrees(70), axis: (x: 1, y: 0, z: 0))
                                .frame(width: 200 + CGFloat(i * 40), height: 200 + CGFloat(i * 40))
                                .scaleEffect(showContent ? 1 : 0.5)
                                .opacity(showContent ? 0.3 : 0)
                                .animation(
                                    .easeInOut(duration: 2).repeatForever(autoreverses: true).delay(
                                        Double(i) * 0.5),
                                    value: showContent
                                )
                        }
                    }
                    .frame(maxWidth: .infinity)

                    // Right: Mission Stats Panel
                    VStack(alignment: .leading, spacing: 20) {
                        // Objective
                        VStack(alignment: .leading, spacing: 4) {
                            Text("OBJECTIVE IDENTIFIED")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(themeColor)
                                .tracking(2)

                            Text(mission.title.uppercased())
                                .font(.system(size: 28, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .shadow(color: themeColor.opacity(0.5), radius: 10)
                        }

                        Divider()
                            .background(Color.white.opacity(0.2))

                        // Stats Grid
                        HStack(spacing: 30) {
                            statItem(icon: "clock.fill", label: "TIME LIMIT", value: "60s")
                            statItem(icon: "bolt.fill", label: "REWARD", value: "+50 XP")
                        }

                        Spacer()

                        // Accept Button (only shows after delay)
                        if showContent {
                            Button(action: {
                                hapticFeedback()
                                onAccept()
                            }) {
                                HStack {
                                    Text("INITIATE MISSION")
                                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                                    Image(systemName: "chevron.right.2")
                                }
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(themeColor)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: themeColor.opacity(0.6), radius: 15)
                            }
                            .transition(.push(from: .bottom))
                        }
                    }
                    .frame(width: 300)
                    .padding(32)
                    .background(.ultraThinMaterial.opacity(0.3))
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(themeColor.opacity(0.5))
                            .frame(width: 2)
                    }
                }

                Spacer()  // Space for bottom dialog
            }
        }
        // Pixel Dialog Overlay
        .pixelDialog(
            text: VoiceScript.forMission(mission.target),
            pixelState: mission.pixelStateBefore,
            isVisible: $isSpeaking,
            onComplete: nil
        )
        .ignoresSafeArea()
        .onAppear {
            startSequence()
        }
    }

    // MARK: - Subviews

    private var backgroundLayer: some View {
        ZStack {
            Color(hex: "050510").ignoresSafeArea()  // Deep space blue/black

            // Hexagon Grid background
            Image("broken_base")  // Reuse existing asset, maybe blurred
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: 10)
                .opacity(0.4)

            // Vignette
            RadialGradient(
                colors: [.clear, .black.opacity(0.8)],
                center: .center,
                startRadius: 200,
                endRadius: 600
            )

            // Refresh scanline effect
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, themeColor.opacity(0.05), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 100)
                .offset(y: showContent ? 400 : -400)
                .animation(
                    .linear(duration: 3).repeatForever(autoreverses: false), value: showContent)
        }
    }

    private var headerView: some View {
        HStack {
            ForEach(0..<10) { _ in
                Rectangle()
                    .fill(Color(hex: "FFE066"))  // Yellow warning
                    .frame(width: 20, height: 4)
                    .rotationEffect(.degrees(45))
            }
            Text(" WARNING: ENERGY CRITICAL ")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundStyle(Color(hex: "FFE066"))
                .padding(.horizontal)
            ForEach(0..<10) { _ in
                Rectangle()
                    .fill(Color(hex: "FFE066"))
                    .frame(width: 20, height: 4)
                    .rotationEffect(.degrees(45))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.8))
        .opacity(warningOpacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever()) {
                warningOpacity = 1.0
            }
        }
    }

    private var gridFloor: some View {
        // Perspective Grid
        Path { path in
            let width: CGFloat = 800
            let height: CGFloat = 400
            let step: CGFloat = 40

            // Horizontal lines
            for i in 0...10 {
                let y = CGFloat(i) * step
                path.move(to: CGPoint(x: -width / 2, y: y))
                path.addLine(to: CGPoint(x: width / 2, y: y))
            }
            // Vertical lines (fanned out)
            for i in -10...10 {
                let x = CGFloat(i) * step * 2
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: CGFloat(i) * step * 5, y: height))
            }
        }
        .stroke(themeColor.opacity(0.3), lineWidth: 1)
        .rotation3DEffect(.degrees(75), axis: (x: 1, y: 0, z: 0))
        .offset(y: 100)
        .frame(height: 200)
    }

    private func statItem(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(themeColor)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.gray)
            }
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Logic

    private var themeColor: Color {
        switch mission.target {
        case .apple: return Color(hex: "FF3B30")  // Red
        case .banana: return Color(hex: "FFD60A")  // Yellow
        case .orange: return Color(hex: "FF9500")  // Orange
        }
    }

    private func startSequence() {
        // 1. Initial Reveal
        withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
            showContent = true
            scaleEffect = 1.0
        }

        // 2. Pixel Speaks
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSpeaking = true  // Triggers Dialog overlay
            audioService.playMissionBriefing(mission) {
                isSpeaking = false  // Auto-close dialog after audio? Or keep it?
                // Usually better to keep text visible until user taps, but for now we follow audio
            }
        }
    }

    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
}

// MARK: - Preview
#Preview("Briefing - Apple") {
    MissionBriefingView(
        mission: Mission.campaign[0],
        audioService: AudioService()
    ) { print("Start!") }
    .previewInterfaceOrientation(.landscapeLeft)
}
