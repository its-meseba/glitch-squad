//
//  HolographicBackground.swift
//  GlitchSquad
//
//  Reusable background with grid and scanline effects.
//

import SwiftUI

struct HolographicBackground: View {
    var themeColor: Color = Color(hex: "00FF94")  // Default Green/Cyan
    @State private var scanlineOffset: CGFloat = -400

    var body: some View {
        ZStack {
            // Deep space background
            Color(hex: "050510").ignoresSafeArea()

            // Texture/Grid (using existing asset or fallback)
            Image("broken_base")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: 10)
                .opacity(0.4)
                .ignoresSafeArea()

            // Vignette
            RadialGradient(
                colors: [.clear, .black.opacity(0.8)],
                center: .center,
                startRadius: 200,
                endRadius: 600
            )
            .ignoresSafeArea()

            // Scanline effect
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, themeColor.opacity(0.1), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 100)
                .offset(y: scanlineOffset)
                .onAppear {
                    withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                        scanlineOffset = 400
                    }
                }
        }
    }
}

#Preview {
    HolographicBackground()
}
