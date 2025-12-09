//
//  CameraPreviewView.swift
//  GlitchSquad
//
//  UIViewRepresentable wrapper for AVCaptureVideoPreviewLayer.
//  Displays live camera feed as SwiftUI view background.
//

import AVFoundation
import SwiftUI

// MARK: - Camera Preview

/// SwiftUI view that displays the live camera feed.
/// Uses UIViewRepresentable to wrap AVCaptureVideoPreviewLayer.
struct CameraPreviewView: UIViewRepresentable {

    /// The camera service providing the capture session
    let session: AVCaptureSession

    func makeUIView(context: Context) -> CameraPreviewUIView {
        let view = CameraPreviewUIView()
        view.session = session
        return view
    }

    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        // Session is set once in makeUIView
    }
}

// MARK: - Preview UIView

/// UIKit view containing the AVCaptureVideoPreviewLayer
final class CameraPreviewUIView: UIView {

    /// Preview layer showing camera output
    private var previewLayer: AVCaptureVideoPreviewLayer?

    /// The capture session to display
    var session: AVCaptureSession? {
        didSet {
            setupPreviewLayer()
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Setup the preview layer with the capture session
    private func setupPreviewLayer() {
        // Remove existing layer
        previewLayer?.removeFromSuperlayer()

        guard let session = session else { return }

        // Create new preview layer
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        layer.frame = bounds

        // Set to 0 = native sensor orientation (landscape)
        if let connection = layer.connection {
            connection.videoRotationAngle = 0
        }

        self.layer.addSublayer(layer)
        self.previewLayer = layer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}

// MARK: - Preview Placeholder

/// Placeholder view for SwiftUI previews (no real camera)
struct CameraPreviewPlaceholder: View {

    var body: some View {
        ZStack {
            // Gradient background mimicking camera view
            LinearGradient(
                colors: [
                    Color(hex: "1A1A2E"),
                    Color(hex: "16213E"),
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Camera icon
            VStack(spacing: 16) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 60, weight: .light))
                    .foregroundStyle(.white.opacity(0.3))

                Text("Camera Preview")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
    }
}

// MARK: - Detection Box Overlay

/// Draws a bounding box around detected objects
/// Shows different colors based on whether object is in the scanning zone
struct DetectionBoxOverlay: View {

    let detection: DetectionResult?
    let screenSize: CGSize
    let scanningZoneRect: CGRect
    let isInZone: Bool

    // Colors for in-zone vs out-of-zone
    private var strokeColors: [Color] {
        if isInZone {
            // Green gradient when in zone
            return [Color(hex: "00FF94"), Color(hex: "00D9FF")]
        } else {
            // Orange/yellow when outside zone (guiding user)
            return [Color(hex: "FFB800"), Color(hex: "FF6B6B")]
        }
    }

    var body: some View {
        GeometryReader { geometry in
            if let detection = detection {
                // Convert normalized coordinates to screen coordinates
                // Note: Vision uses bottom-left origin, SwiftUI uses top-left
                let rect = convertBoundingBox(
                    detection.boundingBox,
                    to: geometry.size
                )

                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: strokeColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isInZone ? 4 : 3
                    )
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .animation(.easeOut(duration: 0.1), value: detection.boundingBox)
                    .animation(.easeOut(duration: 0.2), value: isInZone)

                // Corner accents with zone-aware colors
                ForEach(0..<4, id: \.self) { corner in
                    CornerAccent(corner: corner, isInZone: isInZone)
                        .position(cornerPosition(for: corner, in: rect))
                }

                // "Move to zone" hint when detected but outside
                if !isInZone {
                    Text("Move to zone ↑")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "FFB800"), in: Capsule())
                        .position(x: rect.midX, y: rect.maxY + 30)
                }
            }
        }
    }

    /// Convert Vision bounding box to screen coordinates
    /// accounts for Aspect Fill scaling (cropping)
    private func convertBoundingBox(_ box: CGRect, to size: CGSize) -> CGRect {
        // 1. Determine the scale factor used by Aspect Fill
        // Standard Portrait Camera is 9:16 (720x1280 or 1080x1920) = 0.5625 ratio
        let cameraAspectRatio: CGFloat = 9.0 / 16.0

        // Calculate Scale: max(viewWidth / imageWidth, viewHeight / imageHeight)
        // Since we work in normalized coords, imageWidth=1, imageHeight=cameraAspectRatio (relative to width? No.)
        // Let's us View dimensions.
        // View Height / View Width
        _ = size.width / size.height  // View aspect ratio (unused but kept for documentation)

        // Since View (e.g. 0.46) is skinnier than Camera (0.56),
        // AspectFill scales by HEIGHT.
        // Scaled Image Width = View Height * CameraAspectRatio
        let scaledImageWidth = size.height * cameraAspectRatio
        let scaledImageHeight = size.height

        // 2. Calculate offset (cropping)
        // xOffset is how much the image is shifted left to center it
        let xOffset = (scaledImageWidth - size.width) / 2.0
        let yOffset: CGFloat = 0  // Height matches exactly

        // 3. Map Coordinates
        // box.minX is 0..1 relative to Full Image Width
        let x = (box.minX * scaledImageWidth) - xOffset
        // Vision Y is 0 (bottom) to 1 (top). SwiftUI is 0 (top) to 1 (bottom).
        // box.maxY in Vision = 1.0 - box.minY in SwiftUI logic (if flip needed)
        // Note: box.maxY is the top edge in Vision (visually).
        // In SwiftUI 0 is top.
        // Let's use (1 - maxY) for top edge.
        let y = (1 - box.maxY) * scaledImageHeight - yOffset

        let width = box.width * scaledImageWidth
        let height = box.height * scaledImageHeight

        return CGRect(x: x, y: y, width: width, height: height)
    }

    /// Get position for corner accent
    private func cornerPosition(for corner: Int, in rect: CGRect) -> CGPoint {
        switch corner {
        case 0: return CGPoint(x: rect.minX, y: rect.minY)
        case 1: return CGPoint(x: rect.maxX, y: rect.minY)
        case 2: return CGPoint(x: rect.maxX, y: rect.maxY)
        case 3: return CGPoint(x: rect.minX, y: rect.maxY)
        default: return .zero
        }
    }
}

/// Corner accent for detection box
struct CornerAccent: View {
    let corner: Int
    let isInZone: Bool

    // Colors for in-zone vs out-of-zone
    private var accentColor: Color {
        isInZone ? Color(hex: "00D9FF") : Color(hex: "FFB800")
    }

    var body: some View {
        Path { path in
            let length: CGFloat = 20

            switch corner {
            case 0:  // Top-left
                path.move(to: CGPoint(x: 0, y: length))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: length, y: 0))
            case 1:  // Top-right
                path.move(to: CGPoint(x: -length, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: length))
            case 2:  // Bottom-right
                path.move(to: CGPoint(x: 0, y: -length))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: -length, y: 0))
            case 3:  // Bottom-left
                path.move(to: CGPoint(x: length, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 0, y: -length))
            default:
                break
            }
        }
        .stroke(
            accentColor,
            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
        )
        .shadow(color: accentColor.opacity(0.8), radius: 4)
        .animation(.easeOut(duration: 0.2), value: isInZone)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        CameraPreviewPlaceholder()

        DetectionBoxOverlay(
            detection: DetectionResult(
                label: "apple",
                confidence: 0.85,
                boundingBox: CGRect(x: 0.2, y: 0.3, width: 0.3, height: 0.3)
            ),
            screenSize: UIScreen.main.bounds.size,
            scanningZoneRect: CGRect(x: 0.15, y: 0.25, width: 0.7, height: 0.5),
            isInZone: true
        )
    }
    .ignoresSafeArea()
}
