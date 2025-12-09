//
//  ParentDashboardView.swift
//  GlitchSquad
//
//  Parent-facing dashboard showing activity summary,
//  settings, and controls.
//

import SwiftUI

// MARK: - Parent Dashboard View

/// Parent dashboard with activity reports and settings
struct ParentDashboardView: View {

    @Binding var isPresented: Bool
    @ObservedObject var viewModel: GameViewModel

    @State private var showPinEntry: Bool = true
    @State private var enteredPin: String = ""
    @State private var pinError: Bool = false
    @State private var showSettings: Bool = false

    private let parentSettings = ParentSettings.load()
    private let activityLog = ActivityLog.load()

    var body: some View {
        ZStack {
            // Background
            backgroundGradient

            if showPinEntry && parentSettings.hasCompletedSetup {
                pinEntryView
            } else {
                dashboardContent
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "0D0D1A"),
                Color(hex: "1A1A2E"),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - PIN Entry

    private var pinEntryView: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: "00D9FF"))

            Text("Parent Access")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Enter your 4-digit PIN")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))

            // PIN dots
            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(
                            i < enteredPin.count ? Color(hex: "00D9FF") : Color.white.opacity(0.2)
                        )
                        .frame(width: 16, height: 16)
                }
            }
            .shake(pinError)

            // Number pad
            numberPad

            Spacer()

            // Cancel button
            Button(action: { isPresented = false }) {
                Text("Cancel")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.bottom, 40)
        }
    }

    private var numberPad: some View {
        VStack(spacing: 16) {
            ForEach(0..<3) { row in
                HStack(spacing: 24) {
                    ForEach(1...3, id: \.self) { col in
                        let number = row * 3 + col
                        pinButton(String(number))
                    }
                }
            }

            HStack(spacing: 24) {
                // Empty space
                Color.clear.frame(width: 70, height: 70)

                pinButton("0")

                // Delete
                Button(action: {
                    if !enteredPin.isEmpty {
                        enteredPin.removeLast()
                    }
                }) {
                    Image(systemName: "delete.left")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)
                        .frame(width: 70, height: 70)
                }
            }
        }
    }

    private func pinButton(_ digit: String) -> some View {
        Button(action: {
            guard enteredPin.count < 4 else { return }
            enteredPin += digit

            // Verify when 4 digits entered
            if enteredPin.count == 4 {
                if parentSettings.verifyPin(enteredPin) {
                    withAnimation {
                        showPinEntry = false
                    }
                } else {
                    pinError = true
                    enteredPin = ""

                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(.error)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        pinError = false
                    }
                }
            }
        }) {
            Text(digit)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 70, height: 70)
                .background(.ultraThinMaterial, in: Circle())
        }
    }

    // MARK: - Dashboard Content

    private var dashboardContent: some View {
        VStack(spacing: 0) {
            // Header
            dashboardHeader

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // Today's Activity
                    todayCard

                    // Energy Status
                    energyCard

                    // Collection Progress
                    collectionCard

                    // Quick Actions
                    quickActionsCard
                }
                .padding(20)
            }
        }
    }

    // MARK: - Header

    private var dashboardHeader: some View {
        HStack {
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }

            Spacer()

            Text("Parent Dashboard")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            Button(action: { showSettings = true }) {
                Image(systemName: "gear")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .sheet(isPresented: $showSettings) {
            ParentSettingsView()
        }
    }

    // MARK: - Cards

    private var todayCard: some View {
        DashboardCard(title: "Today's Activity", icon: "calendar") {
            VStack(spacing: 12) {
                StatRow(
                    label: "Missions Completed", value: "\(viewModel.dailyProgress.missionsToday)")
                StatRow(
                    label: "Items Collected", value: "\(viewModel.progress.collectedItems.count)")
                StatRow(label: "Glitch Bits Earned", value: "\(viewModel.glitchBits)")
            }
        }
    }

    private var energyCard: some View {
        DashboardCard(title: "Energy Status", icon: "bolt.fill") {
            VStack(spacing: 12) {
                // Energy bar
                HStack {
                    ForEach(0..<3, id: \.self) { i in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                i < viewModel.dailyProgress.missionsRemaining
                                    ? Color(hex: "00FF94")
                                    : Color.white.opacity(0.2)
                            )
                            .frame(height: 24)
                    }
                }

                Text("\(viewModel.dailyProgress.missionsRemaining) missions remaining today")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }

    private var collectionCard: some View {
        DashboardCard(title: "Collection", icon: "square.grid.2x2") {
            HStack(spacing: 20) {
                ForEach(CollectableItem.allItems) { item in
                    VStack(spacing: 8) {
                        Text(item.emoji)
                            .font(.system(size: 32))
                            .opacity(viewModel.progress.hasCollected(itemType: item.id) ? 1.0 : 0.3)

                        Image(
                            systemName: viewModel.progress.hasCollected(itemType: item.id)
                                ? "checkmark.circle.fill" : "circle"
                        )
                        .foregroundStyle(
                            viewModel.progress.hasCollected(itemType: item.id)
                                ? Color(hex: "00FF94")
                                : Color.white.opacity(0.3)
                        )
                    }
                }
            }
        }
    }

    private var quickActionsCard: some View {
        DashboardCard(title: "Quick Actions", icon: "bolt.circle") {
            VStack(spacing: 12) {
                if viewModel.dailyProgress.missionsRemaining == 0 {
                    ActionButton(
                        title: "Grant Bonus Mission",
                        icon: "plus.circle",
                        color: Color(hex: "FFE066")
                    ) {
                        var progress = viewModel.dailyProgress
                        progress.grantBonusMission()
                        viewModel.updateDailyProgress(progress)

                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    }
                }

                ActionButton(
                    title: "Reset Game Progress",
                    icon: "arrow.counterclockwise",
                    color: Color(hex: "FF6B6B")
                ) {
                    viewModel.resetGame()
                    isPresented = false
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct DashboardCard<Content: View>: View {
    let title: String
    let icon: String
    let content: () -> Content

    init(title: String, icon: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(Color(hex: "00D9FF"))
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }

            content()
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(color.opacity(0.3), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(color.opacity(0.5), lineWidth: 1)
            )
        }
    }
}

// MARK: - Shake Effect

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit: CGFloat = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(
                translationX: amount * sin(animatableData * .pi * shakesPerUnit),
                y: 0
            ))
    }
}

extension View {
    func shake(_ trigger: Bool) -> some View {
        modifier(ShakeModifier(trigger: trigger))
    }
}

struct ShakeModifier: ViewModifier {
    let trigger: Bool
    @State private var shake: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .modifier(ShakeEffect(animatableData: shake))
            .onChange(of: trigger) { _, newValue in
                if newValue {
                    withAnimation(.linear(duration: 0.4)) {
                        shake = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        shake = 0
                    }
                }
            }
    }
}

// MARK: - Preview

#Preview("Parent Dashboard") {
    ParentDashboardView(
        isPresented: .constant(true),
        viewModel: GameViewModel()
    )
}
