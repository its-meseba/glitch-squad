//
//  CameraPreviewView.swift
//  FruitPeek
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
struct DetectionBoxOverlay: View {

    let detection: DetectionResult?
    let screenSize: CGSize

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
                            colors: [
                                Color(hex: "00D9FF"),
                                Color(hex: "00FF94"),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: rect.width, height: rect.height)
                    .position(x: rect.midX, y: rect.midY)
                    .animation(.easeOut(duration: 0.1), value: detection.boundingBox)

                // Corner accents
                ForEach(0..<4, id: \.self) { corner in
                    CornerAccent(corner: corner)
                        .position(cornerPosition(for: corner, in: rect))
                }
            }
        }
    }

    /// Convert Vision bounding box to screen coordinates
    private func convertBoundingBox(_ box: CGRect, to size: CGSize) -> CGRect {
        // Vision: origin at bottom-left, coordinates 0-1
        // SwiftUI: origin at top-left, coordinates in points
        let x = box.minX * size.width
        let y = (1 - box.maxY) * size.height  // Flip Y axis
        let width = box.width * size.width
        let height = box.height * size.height

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
            Color(hex: "00D9FF"),
            style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round)
        )
        .shadow(color: Color(hex: "00D9FF").opacity(0.8), radius: 4)
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
            screenSize: UIScreen.main.bounds.size
        )
    }
    .ignoresSafeArea()
}
