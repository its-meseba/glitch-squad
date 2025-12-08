This is a comprehensive **Product Requirement Document (PRD)** and **UX/UI Design Specification** for your POC.

Given your existing constraints (SwiftUI, YOLOv8 with Apple/Banana/Orange detection, Local-only), we will craft the **"Glitch Squad: Protocol Alpha"**.

This design leverages your existing object detection model but wraps it in the **"Launchpad" narrative** found in your source files, using **Liquid Glass (Glassmorphism)** aesthetics to make it feel premium and modern.

-----

# 📱 Product Requirement Document: "Glitch Squad: Protocol Alpha"

## 1\. Product Identity & Design Language

  * **App Name:** **Glitch Squad** (Subtitle for POC: *Protocol Alpha*)
  * **Concept:** A "Phygital" Scavenger Hunt where a digital robot ("Pixel") breaks down and needs real-world objects to repair himself and his digital base.
  * **Design System:** **"Liquid Glass" (iOS 16+)**
      * **Backgrounds:** Deep, space-like gradients (Deep Purple to Neon Blue) or blurred real-world camera feeds.
      * **Cards:** Translucent white/black with `.ultraThinMaterial` (SwiftUI), thin white borders (1px), and soft, colorful drop shadows (Glow effects).
      * **Typography:** Rounded, bold sans-serif (e.g., *SF Pro Rounded* or *Nunito*). High legibility for kids.
  * **Logo Concept:** A cute, squarish robot face (Pixel) with one eye "glitching" (static noise effect), encased in a glossy, transparent glass sphere.

-----

## 2\. Core Experience Flow (The "Happy Path")

Since you have detection for **Apple, Banana, and Orange**, the narrative will be: *Pixel’s battery is critical and his color sensors are malfunctioning. He needs specific colored organic matter to reboot.*

### **Phase 1: The "Hook" (Onboarding)**

  * **Goal:** Establish the crisis.
  * **Visual:** A dark screen. Static noise audio.
  * **Action:** A "glitch" animation reveals **Pixel** (the robot). He looks sad/broken.
  * **Dialogue (Text + TTS):** "System Failure... Power Critical... Agent, are you there?"

### **Phase 2: The "Mission Briefing" (Launchpad)**

  * **Goal:** Get the child OFF the screen.
  * **UI:** A glass "Mission Card" slides up.
  * **Prompt:** "I need **RED ENERGY** to fix my battery\! Find me an **APPLE**\! You have 60 seconds\!"
  * **Interaction:** A giant, pulsing "START MISSION" button.

### **Phase 3: The "Hunt" (Camera Mode)**

  * **Goal:** Physical movement.
  * **Tech:** Your YOLOv8 implementation.
  * **UI:** Camera feed with a "High-Tech HUD" overlay. A countdown timer ticks loudly.
  * **Action:** The child runs to the kitchen.

### **Phase 4: The "Capture" (Validation)**

  * **Goal:** Validation & Reward.
  * **Action:** Child points camera at an Apple.
  * **Feedback:** The bounding box turns Green. Text: "TARGET LOCKED."
  * **Animation:** The apple is "scanned" (particle effects suck the image into the phone).

### **Phase 5: The "Fix" (Reward)**

  * **Goal:** Dopamine hit.
  * **Visual:** Pixel eats the apple. His battery meter goes up. The glitch effect reduces.
  * **Economy:** User earns "Glitch Bits" (Coins).

-----

## 3\. Detailed Screen Specifications

### **Screen 1: The Base (Home Screen)**

  * **Layout:**
      * **Background:** A 3D parallax room that looks "broken" (cracked walls, flickering lights).
      * **Center Character:** **Pixel** (3D model or animated Sprite). He is idling, occasionally sparking/twitching.
      * **HUD Elements:**
          * Top Left: **"Energy Level"** (Progress Bar, currently low/red).
          * Top Right: **"Backpack"** (Inventory icon - Glass style).
      * **Primary CTA:** A large, floating Glass Card at the bottom: **"MISSION AVAILABLE"**.
          * *Visual:* Pulsing red glow.
          * *Text:* "Emergency\! Reboot Sequence."
  * **SwiftUI Note:** Use `ZStack`. The background is a static image or gradient. The UI elements are `.background(.ultraThinMaterial)` with `.cornerRadius(20)`.

### **Screen 2: Mission Briefing (The Trigger)**

  * **Transition:** Tapping "Mission Available" zooms the camera into Pixel’s face.
  * **UI Layout:**
      * **The Problem:** Pixel speaks (Bubble text): "My logic core is overheating\! I need a **Cooling Agent**."
      * **The Solution:** An icon of a **BANANA** appears (silhouette or blurry at first).
      * **The Constraint:** "Find a **BANANA**. Go to the Kitchen\! GO GO GO\!"
      * **Button:** "ACCEPT MISSION" (Green gradient, full width).
  * **UX Rule:** This screen must be high energy. Use Haptic Feedback (`.impact(.heavy)`) when the button is pressed.

### **Screen 3: The Scanner (Camera/YOLO View)**

  * **This is where your existing code lives.**
  * **UI Overlays (The "Liquid Glass" HUD):**
      * **Reticle:** A square frame in the center `[  ]`.
      * **Top Bar (Glass):**
          * **Left:** "Searching for: [Icon of Banana]"
          * **Right:** Timer "00:59" (Red text, blinking).
      * **Bottom Bar (Glass):**
          * "Flashlight" toggle (for dark corners).
          * "Give Up" button (small, hidden in corner).
  * **Interaction Logic:**
      * **Detection:** When YOLO confidence \> 80% for class "Banana":
        1.  **Haptic:** Continuous vibration.
        2.  **Visual:** Draw the bounding box in **Neon Green**.
        3.  **UI:** Change Top Bar text to "**TARGET ACQUIRED\! HOLD STEADY...**"
        4.  **Auto-Capture:** After 1.5 seconds of steady hold, trigger "Capture."

### **Screen 4: The "Digitization" (Success Screen)**

  * **Animation:**
      * Freeze frame the camera image of the banana.
      * Apply a "grid" effect over the banana.
      * Animate the banana shrinking and flying into a virtual "inventory slot" at the bottom.
  * **Pixel's Reaction:**
      * Pixel appears on screen overlays. "System Stabilized\!"
      * **Sound:** Retro "Power Up" SFX.
  * **Reward Card:**
      * "Mission Complete\!"
      * **Loot:** "+50 Glitch Bits"
      * **Button:** "Return to Base"

-----

## 4\. POC Mission Script (Based on your YOLO Models)

Since you have 3 classes, we will structure the POC as a **3-Stage Tutorial Campaign**.

  * **Mission 01: The Power Source (Apple)**

      * *Context:* Pixel has just booted up and has 5% battery.
      * *Prompt:* "I need Red Energy\! Find an **Apple**\!"
      * *Win State:* Battery restores to 30%.

  * **Mission 02: The Stabilizer (Banana)**

      * *Context:* Pixel is shaking uncontrollably (simulate this by shaking the UI elements in SwiftUI with `.offset`).
      * *Prompt:* "I'm wobbly\! I need a curved Yellow Stabilizer\! Find a **Banana**\!"
      * *Win State:* UI stops shaking.

  * **Mission 03: The Vitamin Shield (Orange)**

      * *Context:* A "Virus" (purple blob) attacks the screen.
      * *Prompt:* "Virus detected\! I need Citrus Shields\! Find an **Orange**\!"
      * *Win State:* The virus dissolves. Pixel is fully repaired. Base transforms from "Broken" to "Clean/Sci-Fi".

-----

## 5\. Technical Implementation Details (SwiftUI)

### **A. Project Structure**

```text
GlitchSquad/
├── App/
│   ├── GlitchSquadApp.swift
│   └── ContentView.swift (Main State Manager)
├── CoreML/
│   └── YOLOv8.mlmodel (Your existing model)
├── Views/
│   ├── HomeView.swift (The Base)
│   ├── MissionBriefingView.swift (The Launchpad)
│   ├── CameraScannerView.swift (Your YOLO implementation wrapped in UI)
│   └── ResultView.swift
├── ViewModels/
│   ├── GameState.swift (ObservableObject: tracks current mission, inventory, coins)
│   └── CameraManager.swift
└── Resources/
    ├── Assets.xcassets (Icons, Liquid Backgrounds)
    └── Sounds (glitch.mp3, success.wav)
```

### **B. The "Liquid Glass" Modifier**

Create a reusable view modifier to keep the design consistent.

```swift
// Example of the design language helper
struct LiquidGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial) // The Glass Effect
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(.white.opacity(0.3), lineWidth: 1) // The frosty border
            )
    }
}
```

### **C. Local Persistence**

Since no Auth/Internet is allowed:

  * Use `UserDefaults` or `@AppStorage` to save:
      * `currentMissionIndex` (0, 1, or 2)
      * `totalCoins`
      * `isBaseRepaired` (Boolean)

-----

## 6\. Why This "Works" for the Requirements

1.  **Launchpad Concept:** The "Briefing" screen explicitly pushes the user *away* from the phone.
2.  **Safety:** It relies on `AVCaptureSession` locally. No images leave the device ("Las Vegas Rule").
3.  **Monetization of Guilt (The "Why"):** Even in a POC, the "Result" screen shows the parent that the child *ran* and *found* something, validating the "Active Play" value proposition.
4.  **Feasibility:** You are just wrapping your existing YOLO detection logic in a gamified state machine (State 1: Briefing -\> State 2: Scanning -\> State 3: Reward).

**Do you want me to write the code for the `HomeView` or the `MissionBriefingView` using this design language to get you started?**