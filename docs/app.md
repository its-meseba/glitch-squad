Context

You are a Senior iOS Engineer and an expert in SwiftUI, Core ML, and Apple's Vision framework. We are building a high-performance scavenger hunt game for kids called "FruitPeek".

Goal

Create a modular, production-ready iOS app where kids find specific fruits (Apple, Banana, Orange) using the camera. The app must feature a futuristic "Liquid Glass" aesthetic (iOS 26 style).

Core Technologies

Language: Swift 6 / SwiftUI.

AI: Core ML (YOLOv8/11). Assume a generic VNCoreMLModel named YOLOv8 is available.

Camera: AVFoundation + Vision.

Architecture: MVVM with strict Separation of Concerns.

Requirements & Game Flow

1. Game Logic (The State Machine)

The game has a sequential flow managed by GameViewModel:

Goal State: Show a large, beautiful card with the target fruit (e.g., "Find an Apple 🍎") and a "Ready?" button.

Hunt State: The card dismisses, the camera is live. A timer counts down.

Lock-On State: When the correct object is detected, a "Lock-On" meter fills up (1-2 seconds of focus required).

Mechanic: Use a "Confidence Bucket". Increment confidence if object is seen, decay if lost. Threshold = 100% to win.

Success State: Confetti, Haptic Feedback, and Sound. Show "Found it!" overlay.

Next Round: Automatically reset logic for the next fruit.

2. Visual Style ("Liquid Glass iOS 26")

Glassmorphism: Use Material.ultraThinMaterial and Material.regular for all UI backgrounds.

Shapes: High corner radiuses (30px+). Use .containerShape(RoundedRectangle...).

Colors: Vibrant, playful gradients that look good behind frosted glass.

Typography: Large, rounded San Francisco font (.design(.rounded)).

3. Modular Structure (Separation of Concerns)

Please generate the file structure and code for the following key modules:

A. CameraService.swift

Manages AVCaptureSession.

Outputs CVPixelBuffer stream via an AsyncStream or Delegate.

Must handle permissions gracefully.

B. DetectorService.swift

Initialize with a Core ML model (use a placeholder YOLOv8 class).

Function: detect(pixelBuffer: CVPixelBuffer) async -> [DetectionResult].

Must use VNImageRequestHandler.

C. GameViewModel.swift

Manages the state: currentGoal, timeLeft, lockOnProgress (0.0 to 1.0).

Contains the "Confidence Bucket" logic.

Outputs specific view states for the UI to consume.

D. LiquidUIComponents.swift

GlassCard(content: View): A reusable wrapper for the glossy look.

LockOnRing(progress: Double): A circular progress view that animates smoothly.

E. MainGameView.swift

The main entry point integrating the Camera background and the Glass UI layers.

Use .matchedGeometryEffect for smooth transitions between "Goal State" and "Hunt State".

Implementation Constraints

Performance: All Vision processing must happen on a background actor/queue to keep the UI at 120Hz/60Hz.

Error Handling: If the model isn't found, use a mock detector that randomly "finds" items for testing purposes.

Simplicity: Keep the code clean and well-commented for a junior developer to understand.

Please start by generating the Folder Structure and then the code for CameraService and GameViewModel.