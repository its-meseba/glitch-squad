# 🤖 Glitch Squad: Protocol Alpha

> A "phygital" scavenger hunt where kids help **Pixel the Robot** repair himself by finding real-world fruits using on-device AI.

![Platform](https://img.shields.io/badge/Platform-iOS%2017%2B-blue?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue?logo=swift)
![CoreML](https://img.shields.io/badge/AI-CoreML%20%2B%20YOLOv8-green)
![License](https://img.shields.io/badge/License-Proprietary-red)

---

## ✨ Overview

**Glitch Squad** is an innovative iOS app that combines physical activity with digital gameplay. Children use the device camera to find real-world objects (fruits) in a race against time, helping a lovable robot character named **Pixel** repair his systems.

### 🎮 Gameplay Loop

1. **The Crisis** — Pixel's systems are failing. He needs organic matter to reboot!
2. **The Mission** — Accept a mission to find a specific fruit (Apple, Banana, or Orange)
3. **The Hunt** — Run around and find the fruit in the real world using the camera
4. **The Capture** — Hold the camera steady on the target to "digitize" it
5. **The Reward** — Pixel gets repaired, you earn Glitch Bits! 🎉

---

## 🎨 Design Language: "Liquid Glass"

The app features a premium **glassmorphism** aesthetic inspired by iOS 26:

- Deep space-like gradient backgrounds
- Translucent glass cards with `ultraThinMaterial`
- Soft glow effects and colorful drop shadows
- Rounded, bold typography (SF Pro Rounded)
- Smooth micro-animations throughout

---

## 🏗️ Project Structure

```
GlitchSquad/
├── GlitchSquadApp.swift          # App entry point
├── Info.plist                    # App configuration
│
├── Models/
│   ├── DailyProgress.swift       # Energy cap & play limits
│   ├── DetectionResult.swift     # YOLO detection output
│   ├── Mission.swift             # Mission definitions (3-stage campaign)
│   └── ParentSettings.swift      # Parental controls
│
├── Services/
│   ├── AudioService.swift        # Sound effects & TTS
│   ├── CameraService.swift       # AVCaptureSession management
│   ├── DetectorService.swift     # Core ML + Vision integration
│   └── ParentNotificationService.swift
│
├── ViewModels/
│   └── GameViewModel.swift       # Central state machine & game logic
│
├── Views/
│   ├── ContentView.swift         # Root navigation
│   ├── IntroView.swift           # Onboarding sequence
│   ├── BaseView.swift            # Pixel's home base (hub)
│   ├── MissionBriefingView.swift # The "launchpad" - get kids moving!
│   ├── MainGameView.swift        # Camera + HUD during hunt
│   ├── DigitizeView.swift        # Capture animation
│   ├── MissionCompleteView.swift # Success celebration
│   ├── CollectionView.swift      # View collected items
│   ├── Components/               # Reusable UI components
│   ├── Onboarding/               # First-time user experience
│   └── Parent/                   # Parental dashboard
│
├── Resources/
│   └── Assets.xcassets/          # Images, icons, colors
│
└── yolov8n.mlpackage/            # Core ML model for fruit detection
```

---

## 🚀 Getting Started

### Prerequisites

- **Xcode 15+** (Swift 5.9)
- **iOS 17.0+** device (or simulator with camera limitations)
- macOS Sonoma or later recommended

### Installation

1. **Clone the repository**
   ```bash
   git clone git@github.com:its-meseba/glitch-squad.git
   cd glitch-squad
   ```

2. **Open in Xcode**
   ```bash
   open GlitchSquad.xcodeproj
   ```
   
   Or use the Swift Package Manager-compatible `Package.swift` for development.

3. **Configure signing**
   - Select your development team in Xcode
   - Update bundle identifier if needed (default: `com.upily.glitchsquad`)

4. **Run on device**
   - The app requires camera access for the full experience
   - Simulator works but object detection requires a real camera feed

---

## 🧠 Technical Highlights

### On-Device AI (Privacy First)

- All object detection happens **locally** using Core ML
- **No images ever leave the device** — "Las Vegas Rule"
- Uses YOLOv8n optimized for real-time inference on mobile

### Architecture: MVVM

- **GameViewModel** manages the entire state machine
- Clear separation between Services, ViewModels, and Views
- Reactive UI with SwiftUI `@Published` properties

### Performance

- Vision processing on background queues (60 Hz target)
- Confidence bucket algorithm prevents false positives
- Temporal stability filtering for reliable detections

---

## 🎯 The 3-Stage Campaign

The POC includes three missions based on available detection classes:

| Mission | Target | Narrative | Win State |
|---------|--------|-----------|-----------|
| **01: Power Source** | 🍎 Apple | "I need Red Energy!" | Battery → 30% |
| **02: Stabilizer** | 🍌 Banana | "I'm wobbly! Need a Yellow Stabilizer!" | UI stops shaking |
| **03: Vitamin Shield** | 🍊 Orange | "Virus detected! Need Citrus Shields!" | Pixel fully repaired |

---

## 🔬 Model Training Lab

The `lab/` directory contains scripts to train custom YOLOv8 models:

```bash
cd lab
pip install -r requirements.txt
python train-gpu.py  # For GPU-accelerated training
```

**Output:** `.mlpackage` file ready for Xcode integration.

See [`lab/README.md`](lab/README.md) for detailed instructions.

---

## 👨‍👩‍👧 Parental Controls

The app includes a parent dashboard with:

- **Daily Energy Cap** — Limits play sessions per day
- **Bonus Mission Granting** — Parents can reward extra play time
- **Activity Log** — See what the child accomplished
- **Force Complete** — Help if child gets stuck

---

## 🛡️ Privacy & Safety

- ✅ No user accounts required
- ✅ No internet connection needed for gameplay
- ✅ No images stored or transmitted
- ✅ Local-only persistence (`UserDefaults` / `@AppStorage`)
- ✅ COPPA-friendly design

---

## 📱 Device Support

| Device | Support |
|--------|---------|
| iPhone (iOS 17+) | ✅ Full |
| iPad (iPadOS 17+) | ✅ Full |
| Simulator | ⚠️ Limited (no camera) |
| Mac (Designed for iPad) | ⚠️ Experimental |

**Orientation:** Landscape only (optimal for camera viewing)

---

## 🤝 Contributing

This is currently a private POC. For questions or contributions, please contact the development team.

---

## 📄 License

Proprietary — All rights reserved by Upily.

---

## 🙏 Acknowledgments

- **Ultralytics** for YOLOv8
- **Roboflow** for dataset management
- Apple's **Vision** and **Core ML** frameworks

---

<p align="center">
  <strong>Get kids moving. Make screen time active time.</strong><br>
  <em>Built with ❤️ by the Upily team</em>
</p>
