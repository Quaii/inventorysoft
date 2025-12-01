import SwiftUI

// MARK: - Texture Modifiers

struct NoiseOverlayModifier: ViewModifier {
    let opacity: Double

    func body(content: Content) -> some View {
        content
    }
}

struct MicroGridModifier: ViewModifier {
    let color: Color
    let opacity: Double
    let spacing: CGFloat

    func body(content: Content) -> some View {
        content
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
