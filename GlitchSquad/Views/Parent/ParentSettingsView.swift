//
//  ParentSettingsView.swift
//  GlitchSquad
//
//  Parent settings for PIN, notifications, and preferences.
//

import SwiftUI

// MARK: - Parent Settings View

struct ParentSettingsView: View {

    @Environment(\.dismiss) private var dismiss
    @State private var settings = ParentSettings.load()
    @State private var showPinSetup: Bool = false
    @State private var newPin: String = ""
    @State private var confirmPin: String = ""
    @State private var pinSetupStep: Int = 1
    @State private var pinMismatch: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "1A1A2E")
                    .ignoresSafeArea()

                List {
                    // PIN Section
                    Section {
                        Button(action: { showPinSetup = true }) {
                            HStack {
                                Label("Change PIN", systemImage: "lock")
                                Spacer()
                                if settings.hasCompletedSetup {
                                    Text("Set")
                                        .foregroundStyle(.secondary)
                                } else {
                                    Text("Not Set")
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    } header: {
                        Text("Security")
                    }

                    // Notifications Section
                    Section {
                        Toggle(isOn: $settings.notificationsEnabled) {
                            Label("Mission Notifications", systemImage: "bell")
                        }
                        .onChange(of: settings.notificationsEnabled) { _, _ in
                            settings.save()
                        }

                        Toggle(isOn: $settings.weeklySummaryEnabled) {
                            Label("Weekly Summary", systemImage: "chart.bar")
                        }
                        .onChange(of: settings.weeklySummaryEnabled) { _, _ in
                            settings.save()
                        }
                    } header: {
                        Text("Notifications")
                    }

                    // Privacy Section
                    Section {
                        NavigationLink {
                            PrivacyInfoView()
                        } label: {
                            Label("Privacy Information", systemImage: "lock.shield")
                        }
                    } header: {
                        Text("Privacy")
                    } footer: {
                        Text(
                            "All photos are processed on-device and instantly deleted. No data leaves your device."
                        )
                    }

                    // About Section
                    Section {
                        HStack {
                            Text("Version")
                            Spacer()
                            Text("1.0.0 (POC)")
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text("About")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showPinSetup) {
                pinSetupView
            }
        }
    }

    // MARK: - PIN Setup

    private var pinSetupView: some View {
        ZStack {
            Color(hex: "1A1A2E")
                .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color(hex: "00D9FF"))

                Text(pinSetupStep == 1 ? "Create a 4-digit PIN" : "Confirm your PIN")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(
                    pinSetupStep == 1
                        ? "This PIN protects parent settings"
                        : "Enter the same PIN again"
                )
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))

                // PIN dots
                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { i in
                        let currentPin = pinSetupStep == 1 ? newPin : confirmPin
                        Circle()
                            .fill(
                                i < currentPin.count
                                    ? Color(hex: "00D9FF") : Color.white.opacity(0.2)
                            )
                            .frame(width: 16, height: 16)
                    }
                }
                .shake(pinMismatch)

                if pinMismatch {
                    Text("PINs don't match. Try again.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.red)
                }

                // Number pad
                setupNumberPad

                Spacer()

                Button("Cancel") {
                    resetPinSetup()
                    showPinSetup = false
                }
                .foregroundStyle(.white.opacity(0.5))
                .padding(.bottom, 40)
            }
        }
    }

    private var setupNumberPad: some View {
        VStack(spacing: 16) {
            ForEach(0..<3) { row in
                HStack(spacing: 24) {
                    ForEach(1...3, id: \.self) { col in
                        let number = row * 3 + col
                        setupPinButton(String(number))
                    }
                }
            }

            HStack(spacing: 24) {
                Color.clear.frame(width: 70, height: 70)
                setupPinButton("0")
                Button(action: {
                    if pinSetupStep == 1 && !newPin.isEmpty {
                        newPin.removeLast()
                    } else if pinSetupStep == 2 && !confirmPin.isEmpty {
                        confirmPin.removeLast()
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

    private func setupPinButton(_ digit: String) -> some View {
        Button(action: {
            if pinSetupStep == 1 {
                guard newPin.count < 4 else { return }
                newPin += digit

                if newPin.count == 4 {
                    withAnimation {
                        pinSetupStep = 2
                    }
                }
            } else {
                guard confirmPin.count < 4 else { return }
                confirmPin += digit

                if confirmPin.count == 4 {
                    if newPin == confirmPin {
                        // Success!
                        settings.setPin(newPin)
                        resetPinSetup()
                        showPinSetup = false

                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                    } else {
                        // Mismatch
                        pinMismatch = true
                        confirmPin = ""

                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.error)

                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            pinMismatch = false
                            pinSetupStep = 1
                            newPin = ""
                        }
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

    private func resetPinSetup() {
        newPin = ""
        confirmPin = ""
        pinSetupStep = 1
        pinMismatch = false
    }
}

// MARK: - Preview

#Preview("Parent Settings") {
    ParentSettingsView()
}
