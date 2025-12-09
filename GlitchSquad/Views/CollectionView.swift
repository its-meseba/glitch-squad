//
//  CollectionView.swift
//  GlitchSquad
//
//  Gallery view showing all collected and locked items.
//  Accessed from the BaseView.
//

import SwiftUI

// MARK: - Collection View

/// Gallery showing collected items and locked placeholders
struct CollectionView: View {

    let progress: GameProgress
    let onDismiss: () -> Void

    @State private var showContent: Bool = false
    @State private var selectedItem: CollectedItem?

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        ZStack {
            // Background
            backgroundGradient

            VStack(spacing: 0) {
                // Header
                header

                // Collection grid
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(CollectableItem.allItems) { item in
                            CollectionItemCard(
                                item: item,
                                isCollected: progress.hasCollected(itemType: item.id),
                                collectedItem: progress.collectedItems.first {
                                    $0.itemType == item.id
                                }
                            )
                            .onTapGesture {
                                if let collected = progress.collectedItems.first(where: {
                                    $0.itemType == item.id
                                }) {
                                    selectedItem = collected
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
                .opacity(showContent ? 1 : 0)
            }
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailSheet(item: item)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.2)) {
                showContent = true
            }
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                Color(hex: "0D0D1A"),
                Color(hex: "1A1A2E"),
                Color(hex: "16213E"),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }

            Spacer()

            VStack(spacing: 4) {
                Text("MY COLLECTION")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(
                    "\(progress.collectedItems.count) of \(CollectableItem.allItems.count) collected"
                )
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
            }

            Spacer()

            // Placeholder for symmetry
            Color.clear
                .frame(width: 42, height: 42)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Collection Item Card

struct CollectionItemCard: View {

    let item: CollectableItem
    let isCollected: Bool
    let collectedItem: CollectedItem?

    @State private var glowPulse: Bool = false

    var body: some View {
        VStack(spacing: 12) {
            // Image container
            ZStack {
                // Background glow for collected items
                if isCollected {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color(hex: "00D9FF").opacity(0.3), Color.clear],
                                center: .center,
                                startRadius: 10,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(glowPulse ? 1.1 : 1.0)
                }

                // Item image or locked placeholder
                if isCollected {
                    Image(item.imageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                } else {
                    Image("item_locked")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .opacity(0.6)
                }
            }
            .frame(height: 90)

            // Name
            Text(isCollected ? item.name : "???")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    isCollected
                        ? LinearGradient(
                            colors: [
                                Color(hex: "00D9FF").opacity(0.5),
                                Color(hex: "00FF94").opacity(0.3),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [.white.opacity(0.1)], startPoint: .top, endPoint: .bottom),
                    lineWidth: 1
                )
        )
        .onAppear {
            if isCollected {
                withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                    glowPulse = true
                }
            }
        }
    }
}

// MARK: - Item Detail Sheet

struct ItemDetailSheet: View {

    let item: CollectedItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            // Background
            Color(hex: "1A1A2E")
                .ignoresSafeArea()

            VStack(spacing: 24) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                // Item image
                Image(item.collectionImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 200)
                    .shadow(color: Color(hex: "00D9FF").opacity(0.5), radius: 30)

                // Item name
                Text(item.displayName)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                // Details
                VStack(spacing: 8) {
                    DetailRow(label: "Mission", value: item.missionTitle)
                    DetailRow(label: "Collected", value: formattedDate)
                }
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 40)

                Spacer()
                Spacer()
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: item.collectedAt)
    }
}

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Preview

#Preview("Collection - Empty") {
    CollectionView(
        progress: GameProgress(),
        onDismiss: {}
    )
}

#Preview("Collection - Some Items") {
    var progress = GameProgress()
    progress.collectedItems = [
        CollectedItem(itemType: "apple", missionTitle: "The Power Source"),
        CollectedItem(itemType: "banana", missionTitle: "The Stabilizer"),
    ]
    return CollectionView(
        progress: progress,
        onDismiss: {}
    )
}
