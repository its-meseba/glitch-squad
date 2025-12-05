//
//  FruitPeekApp.swift
//  FruitPeek
//
//  A scavenger hunt game for kids to find fruits using the camera.
//  Features "Liquid Glass iOS 26" aesthetic with Core ML detection.
//

import SwiftUI

@main
struct FruitPeekApp: App {
    var body: some Scene {
        WindowGroup {
            MainGameView()
                .preferredColorScheme(.dark)  // Best for glassmorphism
        }
    }
}
