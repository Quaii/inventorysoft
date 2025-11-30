import SwiftUI

// MARK: - Texture Modifiers

struct NoiseOverlayModifier: ViewModifier {
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    Canvas { context, size in
                        context.fill(
                            Path(CGRect(origin: .zero, size: size)),
                            with: .color(.white.opacity(opacity))
                        )
                        // Note: Real noise generation is expensive in SwiftUI Canvas.
                        // Using a static pattern or image is better.
                        // For this implementation, we simulate a subtle grain using a high-frequency pattern
                        // or we could use a tiled image if available.
                        // Here we'll use a simple dot pattern to simulate texture.

                        let dotSize: CGFloat = 1
                        let spacing: CGFloat = 4
                        for x in stride(from: 0, to: size.width, by: spacing) {
                            for y in stride(from: 0, to: size.height, by: spacing) {
                                if Bool.random() {
                                    let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                                    context.fill(
                                        Path(rect), with: .color(.white.opacity(opacity * 0.5)))
                                }
                            }
                        }
                    }
                }
                .allowsHitTesting(false)
            )
    }
}

struct MicroGridModifier: ViewModifier {
    let color: Color
    let opacity: Double
    let spacing: CGFloat

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Path { path in
                        let width = proxy.size.width
                        let height = proxy.size.height

                        for x in stride(from: 0, to: width, by: spacing) {
                            path.move(to: CGPoint(x: x, y: 0))
                            path.addLine(to: CGPoint(x: x, y: height))
                        }

                        for y in stride(from: 0, to: height, by: spacing) {
                            path.move(to: CGPoint(x: 0, y: y))
                            path.addLine(to: CGPoint(x: width, y: y))
                        }
                    }
                    .stroke(color.opacity(opacity), lineWidth: 0.5)
                }
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Applies a subtle noise overlay to add texture and reduce banding
    func noiseOverlay(opacity: Double = 0.03) -> some View {
        modifier(NoiseOverlayModifier(opacity: opacity))
    }

    /// Applies a micro-grid pattern to the background
    func microGrid(color: Color = .white, opacity: Double = 0.05, spacing: CGFloat = 20)
        -> some View
    {
        modifier(MicroGridModifier(color: color, opacity: opacity, spacing: spacing))
    }
}
