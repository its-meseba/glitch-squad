# Resource Generation Guide - Glitch Squad: Protocol Alpha

> **Purpose**: Generate AI assets (images, audio) for the Glitch Squad POC.
> 
> After generating each resource, place it at the specified project path.

---

## 📁 Directory Structure

```
GlitchSquad/Resources/
├── Assets.xcassets/
│   ├── AppIcon.appiconset/        # App icons
│   ├── Pixel/                     # Character images
│   │   ├── pixel_idle.imageset/
│   │   ├── pixel_happy.imageset/
│   │   ├── pixel_sad.imageset/
│   │   └── pixel_glitch.imageset/
│   └── Backgrounds/
│       └── broken_base.imageset/
├── Sounds/
│   ├── glitch_static.mp3          # SFX
│   ├── mission_accept.mp3
│   ├── target_lock.mp3
│   ├── digitize_scan.mp3
│   ├── success_powerup.mp3
│   ├── system_boot.mp3
│   └── Voice/                     # Voice lines
│       ├── intro_greeting.mp3
│       ├── mission_apple.mp3
│       ├── mission_banana.mp3
│       ├── mission_orange.mp3
│       ├── success_1.mp3
│       ├── success_2.mp3
│       ├── success_3.mp3
│       └── game_complete.mp3
└── yolov8n.mlpackage/
```

---

## 📐 Image Specifications Summary

| Asset | Size (px) | Ratio | Format |
|-------|-----------|-------|--------|
| Pixel Idle | 512×512 | 1:1 | PNG (transparent) |
| Pixel Happy | 512×512 | 1:1 | PNG (transparent) |
| Pixel Sad | 512×512 | 1:1 | PNG (transparent) |
| Pixel Glitch | 512×512 | 1:1 | PNG (transparent) |
| Broken Base | 2048×1024 | 2:1 | PNG |
| Base Stage 1-4 | 800×600 | 4:3 | PNG (transparent) |
| Collected Apple | 256×256 | 1:1 | PNG (transparent) |
| Collected Banana | 256×256 | 1:1 | PNG (transparent) |
| Collected Orange | 256×256 | 1:1 | PNG (transparent) |
| Locked Item | 256×256 | 1:1 | PNG (transparent) |
| App Icon | 1024×1024 | 1:1 | PNG (no transparency) |

---

## 🤖 Character: Pixel (The Robot)

### Image 1: Pixel Idle
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Pixel/pixel_idle.imageset/`
- **Size**: `512×512 px` (1:1 square)
- **Format**: PNG with transparent background
- **Prompt**:
```
A cute, friendly robot mascot for a kids app, named "Pixel". Square-ish head with rounded corners, two large circular LED eyes (one blue, one flickering/static). Small antenna on top. Simple geometric body with a glowing circular chest panel. Pastel purple and blue color scheme. Kawaii style, minimal detail, clean vector look. Transparent PNG background. 512x512 pixels, 1:1 square ratio. Slight idle bobbing pose.
```

### Image 2: Pixel Happy
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Pixel/pixel_happy.imageset/`
- **Size**: `512×512 px` (1:1 square)
- **Format**: PNG with transparent background
- **Prompt**:
```
Same cute robot mascot "Pixel" but in a happy, celebrating pose. Both circular LED eyes are bright cyan blue and shaped like happy crescents (^_^). Small sparkle effects around the head. Arms raised in celebration. Glowing green chest panel. Pastel purple and blue color scheme. Kawaii style, minimal detail, clean vector look. Transparent PNG background. 512x512 pixels, 1:1 square ratio.
```

### Image 3: Pixel Sad/Low Battery
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Pixel/pixel_sad.imageset/`
- **Size**: `512×512 px` (1:1 square)
- **Format**: PNG with transparent background
- **Prompt**:
```
Same cute robot mascot "Pixel" but looking sad and low on power. LED eyes are dim orange/red and droopy. Small "ZZZ" or low battery icon floating near head. Chest panel is dimly lit red. Slight grey desaturation. Arms hanging down. Pastel purple body with muted colors. Kawaii style, minimal detail, clean vector look. Transparent PNG background. 512x512 pixels, 1:1 square ratio.
```

### Image 4: Pixel Glitching
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Pixel/pixel_glitch.imageset/`
- **Size**: `512×512 px` (1:1 square)
- **Format**: PNG with transparent background
- **Prompt**:
```
Same cute robot mascot "Pixel" but with a glitch effect. One eye shows static/noise pattern. RGB split chromatic aberration effect on the outline. Small lightning/spark effects around the body. Horizontal scan lines visible. Chest panel flickering between red and blue. Slightly distorted/offset double vision effect. Kawaii style but with digital corruption aesthetic. Transparent PNG background. 512x512 pixels, 1:1 square ratio.
```

---

## 🏠 Background: Broken Base

- **Path**: `GlitchSquad/Resources/Assets.xcassets/Backgrounds/broken_base.imageset/`
- **Size**: `2048×1024 px` (2:1 landscape)
- **Format**: PNG
- **Prompt**:
```
A dark, futuristic control room interior for a kids game. Moody deep purple and dark blue color scheme. Cracked holographic screens on walls. Flickering neon lights (some broken). Exposed wires with small sparks. Central circular platform in the middle. Subtle grid pattern on floor. Sci-fi aesthetic but child-friendly (not scary). Slightly foggy/misty atmosphere. 2048x1024 pixels, 2:1 landscape orientation for iPad. Vector/illustrated style.
```

---

## 🏝️ Base Stages (Isometric Island)

> **Concept**: A floating island "Eco Dome" that evolves from broken to fully restored as missions complete. Isometric 3D style, child-friendly, with Pixel standing on it.

### Base Stage 1: Broken
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Base/base_stage_1.imageset/`
- **Size**: `800×600 px` (4:3)
- **Format**: PNG with transparent background
- **Prompt**:
```
Isometric floating island for kids game, stage 1 "broken". Small rocky platform floating in space. Dark purple and grey colors, cracked ground, dead tree stump, no grass. Glitchy digital artifacts around edges. Dim red warning lights. Sad, damaged look but child-friendly (not scary). Simple low-poly 3D illustration style. 800x600 pixels, transparent background.
```

### Base Stage 2: Stabilizing
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Base/base_stage_2.imageset/`
- **Size**: `800×600 px` (4:3)
- **Format**: PNG with transparent background
- **Prompt**:
```
Isometric floating island for kids game, stage 2 "stabilizing". Same rocky platform but starting to heal. Some green patches of grass appearing. Small sapling tree growing. Colors transitioning from grey to soft green/blue. Yellow energy particles floating. Hopeful feeling. Simple low-poly 3D illustration style. 800x600 pixels, transparent background.
```

### Base Stage 3: Growing
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Base/base_stage_3.imageset/`
- **Size**: `800×600 px` (4:3)
- **Format**: PNG with transparent background
- **Prompt**:
```
Isometric floating island for kids game, stage 3 "growing". Vibrant and healthy floating island. Lush green grass, medium tree with leaves, colorful flowers. Small pond or water feature. Soft blue and green colors. Floating sparkles. Happy, nature-filled vibe. Simple low-poly 3D illustration style. 800x600 pixels, transparent background.
```

### Base Stage 4: Restored (Paradise)
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Base/base_stage_4.imageset/`
- **Size**: `800×600 px` (4:3)
- **Format**: PNG with transparent background
- **Prompt**:
```
Isometric floating island for kids game, stage 4 "fully restored paradise". Beautiful floating eco dome island. Large healthy tree with glowing fruit. Rainbow flowers, butterflies, small waterfall. Golden sunlight effects. Magical floating crystals. Celebration confetti particles. Pure joy and accomplishment feeling. Simple low-poly 3D illustration style. 800x600 pixels, transparent background.
```

---

## 🎒 Collection Items

> **Concept**: Stylized versions of collected items for the gallery/collection view. More decorative than realistic.

### Collected Apple
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Collection/collected_apple.imageset/`
- **Size**: `256×256 px` (1:1)
- **Format**: PNG with transparent background
- **Prompt**:
```
Stylized cartoon apple for kids game collection. Shiny red apple with cute kawaii face (small happy eyes, tiny smile). Single green leaf on stem. Subtle sparkle effects. Glossy, 3D look with soft shadows. Vibrant saturated colors. Transparent background. 256x256 pixels.
```

### Collected Banana
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Collection/collected_banana.imageset/`
- **Size**: `256×256 px` (1:1)
- **Format**: PNG with transparent background
- **Prompt**:
```
Stylized cartoon banana for kids game collection. Bright yellow banana with cute kawaii face (small happy eyes, tiny smile). Curved shape, some brown spots at tips. Subtle sparkle effects. Glossy, 3D look with soft shadows. Vibrant saturated colors. Transparent background. 256x256 pixels.
```

### Collected Orange
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Collection/collected_orange.imageset/`
- **Size**: `256×256 px` (1:1)
- **Format**: PNG with transparent background
- **Prompt**:
```
Stylized cartoon orange for kids game collection. Bright orange citrus fruit with cute kawaii face (small happy eyes, tiny smile). Small green leaf on top. Subtle dimpled texture. Sparkle effects. Glossy, 3D look with soft shadows. Vibrant saturated colors. Transparent background. 256x256 pixels.
```

### Locked Item Slot
- **Path**: `GlitchSquad/Resources/Assets.xcassets/Collection/item_locked.imageset/`
- **Size**: `256×256 px` (1:1)  
- **Format**: PNG with transparent background
- **Prompt**:
```
Mystery locked item icon for kids game. Large question mark "?" in center. Silhouette style with dark grey/purple color. Subtle sparkle suggesting something hidden. Glassmorphism frosted glass effect. Rounded square shape. Inviting "discover me" feeling. Transparent background. 256x256 pixels.
```

---

## 🎵 App Icon

- **Path**: `GlitchSquad/Resources/Assets.xcassets/AppIcon.appiconset/`
- **Size**: `1024×1024 px` (1:1 square)
- **Format**: PNG (no transparency, solid background)
- **Prompt**:
```
App icon for "Glitch Squad" kids game. A cute, squarish robot face (Pixel) with one normal cyan LED eye and one eye showing static/glitch pattern. Enclosed in a glossy transparent glass sphere with subtle reflections. Deep purple to neon blue gradient background. Small sparkle effects. Modern iOS app icon style, clean and readable at small sizes. 1024x1024 pixels, 1:1 square ratio. No transparency.
```


---

## 🔊 Sound Effects

### SFX 1: Glitch Static
- **Path**: `GlitchSquad/Resources/Sounds/glitch_static.mp3`
- **Duration**: 1-2 seconds
- **Prompt**:
```
Short digital glitch/static noise sound, 1-2 seconds. Like TV static mixed with digital corruption. Child-friendly (not harsh or scary). Use for robot reveal animation.
```

### SFX 2: System Boot
- **Path**: `GlitchSquad/Resources/Sounds/system_boot.mp3`
- **Duration**: 2-3 seconds
- **Prompt**:
```
Robot powering on sound, 2-3 seconds. Mechanical whir transitioning to electronic hum. Like a friendly computer booting up. Ends with a cheerful "ready" beep.
```

### SFX 3: Mission Accept
- **Path**: `GlitchSquad/Resources/Sounds/mission_accept.mp3`
- **Duration**: 1 second
- **Prompt**:
```
Energetic "mission accepted" sound, 1 second. Upward rising synth tone with a satisfying click. Like a video game start button. Positive and exciting for kids.
```

### SFX 4: Target Lock
- **Path**: `GlitchSquad/Resources/Sounds/target_lock.mp3`
- **Duration**: 0.5-1 second (loopable)
- **Prompt**:
```
Futuristic targeting/locking sound, 0.5-1 second. Subtle electronic beeping that intensifies. Like a sci-fi scanner acquiring target. Can loop seamlessly.
```

### SFX 5: Digitize Scan
- **Path**: `GlitchSquad/Resources/Sounds/digitize_scan.mp3`
- **Duration**: 2 seconds
- **Prompt**:
```
Digital scanning/absorption sound, 2 seconds. Rising electronic whoosh that ends with a satisfying "digitization complete" tone. Like sucking data into a computer.
```

### SFX 6: Success Power-Up
- **Path**: `GlitchSquad/Resources/Sounds/success_powerup.mp3`
- **Duration**: 2-3 seconds
- **Prompt**:
```
Triumphant power-up jingle, 2-3 seconds. Classic video game "you got the item" fanfare. Ascending notes ending on a high positive note. Child-friendly and celebratory.
```

---

## 🗣️ Voice Lines (Pixel's Voice)

> **Voice Style**: Friendly robot voice for kids. Slightly high-pitched, warm, with subtle digital/robotic processing. NOT scary or cold. Think "helpful AI assistant for children". Use ElevenLabs, Suno, or similar.

### Voice 1: Intro Greeting
- **Path**: `GlitchSquad/Resources/Sounds/Voice/intro_greeting.mp3`
- **Duration**: 5-6 seconds
- **Script**:
```
"System Failure... Power Critical... Agent, are you there? I'm Pixel. I need your help!"
```
- **Prompt**:
```
Friendly robot voice speaking: "System Failure... Power Critical... Agent, are you there? I'm Pixel. I need your help!" Start with distorted/glitchy effect on first words, then clearer. Warm, slightly worried but hopeful tone. Child-friendly AI voice with subtle robotic processing.
```

### Voice 2: Mission Apple
- **Path**: `GlitchSquad/Resources/Sounds/Voice/mission_apple.mp3`
- **Duration**: 4-5 seconds
- **Script**:
```
"My battery is almost empty! I need RED ENERGY to power up. Find me an APPLE! Go go go!"
```
- **Prompt**:
```
Friendly robot voice, urgent but playful: "My battery is almost empty! I need RED ENERGY to power up. Find me an APPLE! Go go go!" Emphasize "APPLE" and "Go go go" with excitement. Kid-friendly robotic voice.
```

### Voice 3: Mission Banana
- **Path**: `GlitchSquad/Resources/Sounds/Voice/mission_banana.mp3`
- **Duration**: 4-5 seconds
- **Script**:
```
"Whoa! I'm all wobbly! I need a YELLOW STABILIZER to fix my balance. Find a BANANA!"
```
- **Prompt**:
```
Friendly robot voice, wobbly/shaky delivery: "Whoa! I'm all wobbly! I need a YELLOW STABILIZER to fix my balance. Find a BANANA!" Voice should sound unsteady at start, then more determined. Emphasize "BANANA" with hope.
```

### Voice 4: Mission Orange
- **Path**: `GlitchSquad/Resources/Sounds/Voice/mission_orange.mp3`
- **Duration**: 4-5 seconds
- **Script**:
```
"Warning! Virus detected! I need CITRUS SHIELDS to fight it off. Quick, find an ORANGE!"
```
- **Prompt**:
```
Friendly robot voice, alert but not scary: "Warning! Virus detected! I need CITRUS SHIELDS to fight it off. Quick, find an ORANGE!" Start with alarm-like urgency, then hopeful. Emphasize "ORANGE" clearly.
```

### Voice 5: Success Line 1
- **Path**: `GlitchSquad/Resources/Sounds/Voice/success_1.mp3`
- **Duration**: 2-3 seconds
- **Script**:
```
"YES! Target acquired! Systems charging..."
```
- **Prompt**:
```
Excited robot voice: "YES! Target acquired! Systems charging..." Happy and relieved. Sound of powering up at the end. Kid-friendly celebration tone.
```

### Voice 6: Success Line 2
- **Path**: `GlitchSquad/Resources/Sounds/Voice/success_2.mp3`
- **Duration**: 2-3 seconds
- **Script**:
```
"Perfect! My circuits are tingling!"
```
- **Prompt**:
```
Joyful robot voice: "Perfect! My circuits are tingling!" Playful and silly. Slight giggle or excited beep at end.
```

### Voice 7: Success Line 3
- **Path**: `GlitchSquad/Resources/Sounds/Voice/success_3.mp3`
- **Duration**: 2-3 seconds
- **Script**:
```
"Amazing work, Agent! Power levels rising!"
```
- **Prompt**:
```
Proud robot voice: "Amazing work, Agent! Power levels rising!" Grateful and impressed. Sounds like power meter filling up at end.
```

### Voice 8: Game Complete
- **Path**: `GlitchSquad/Resources/Sounds/Voice/game_complete.mp3`
- **Duration**: 5-6 seconds
- **Script**:
```
"You did it! All systems restored! Thank you, Agent. You're the best repair crew in the galaxy!"
```
- **Prompt**:
```
Joyful, fully-powered robot voice: "You did it! All systems restored! Thank you, Agent. You're the best repair crew in the galaxy!" Full of energy and gratitude. Celebratory fanfare-style ending. Clear and strong voice (no more glitches).
```

---

## ✅ Generation Checklist

### Images - Character & Background
- [x] `pixel_idle.png` — 512×512 px, 1:1, transparent PNG ✅
- [x] `pixel_happy.png` — 512×512 px, 1:1, transparent PNG ✅
- [x] `pixel_sad.png` — 512×512 px, 1:1, transparent PNG ✅
- [x] `pixel_glitch.png` — 512×512 px, 1:1, transparent PNG ✅
- [x] `broken_base.png` — 2048×1024 px, 2:1, PNG ✅
- [x] `AppIcon.png` — 1024×1024 px, 1:1, PNG (no transparency) ✅

### Images - Base Stages (NEW)
- [ ] `base_stage_1.png` — 800×600 px, 4:3, transparent PNG (Broken)
- [ ] `base_stage_2.png` — 800×600 px, 4:3, transparent PNG (Stabilizing)
- [ ] `base_stage_3.png` — 800×600 px, 4:3, transparent PNG (Growing)
- [ ] `base_stage_4.png` — 800×600 px, 4:3, transparent PNG (Restored)

### Images - Collection Items (NEW)
- [ ] `collected_apple.png` — 256×256 px, 1:1, transparent PNG
- [ ] `collected_banana.png` — 256×256 px, 1:1, transparent PNG
- [ ] `collected_orange.png` — 256×256 px, 1:1, transparent PNG
- [ ] `item_locked.png` — 256×256 px, 1:1, transparent PNG

### Sound Effects
- [ ] `glitch_static.mp3` — 1-2 sec
- [ ] `system_boot.mp3` — 2-3 sec
- [ ] `mission_accept.mp3` — 1 sec
- [ ] `target_lock.mp3` — 0.5-1 sec
- [ ] `digitize_scan.mp3` — 2 sec
- [ ] `success_powerup.mp3` — 2-3 sec

### Voice Lines
- [ ] `Voice/intro_greeting.mp3` — 5-6 sec
- [ ] `Voice/mission_apple.mp3` — 4-5 sec
- [ ] `Voice/mission_banana.mp3` — 4-5 sec
- [ ] `Voice/mission_orange.mp3` — 4-5 sec
- [ ] `Voice/success_1.mp3` — 2-3 sec
- [ ] `Voice/success_2.mp3` — 2-3 sec
- [ ] `Voice/success_3.mp3` — 2-3 sec
- [ ] `Voice/game_complete.mp3` — 5-6 sec

### Final Steps
- [ ] Place all files in `GlitchSquad/Resources/`
- [ ] Run `xcodegen generate`
- [ ] Build and test on device
