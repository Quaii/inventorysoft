import SwiftUI

// MARK: - Glow Modifiers

struct NeonGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
    }
}

struct GradientGlowModifier: ViewModifier {
    let colors: [Color]
    let radius: CGFloat
    let opacity: Double
    let startPoint: UnitPoint
    let endPoint: UnitPoint

    func body(content: Content) -> some View {
        content
    }
}

struct AmbientLightModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
    }
}

struct GlassMorphismModifier: ViewModifier {
    let cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
    }
}

// MARK: - View Extensions

extension View {
    /// Applies a neon glow effect with double layers for intensity
    func neonGlow(color: Color, radius: CGFloat = 10, opacity: Double = 0.8) -> some View {
        modifier(NeonGlowModifier(color: color, radius: radius, opacity: opacity))
    }

    /// Applies a gradient glow effect behind the content
    func gradientGlow(
        colors: [Color], radius: CGFloat = 15, opacity: Double = 0.6,
        startPoint: UnitPoint = .topLeading, endPoint: UnitPoint = .bottomTrailing
    ) -> some View {
        modifier(
            GradientGlowModifier(
                colors: colors, radius: radius, opacity: opacity, startPoint: startPoint,
                endPoint: endPoint))
    }

    /// Applies a soft ambient light bleed behind the content
    func ambientLight(color: Color, radius: CGFloat = 30, opacity: Double = 0.3) -> some View {
        modifier(AmbientLightModifier(color: color, radius: radius, opacity: opacity))
    }

    /// Applies a "glass" edge light effect
    /// Applies a "glass" edge light effect - Disabled
    func glassEdge(color: Color = .white, opacity: Double = 0.3, cornerRadius: CGFloat = 12)
        -> some View
    {
        self
    }

    /// Applies a glassmorphism effect with blur and shadow
    func glass(cornerRadius: CGFloat = 12) -> some View {
        modifier(GlassMorphismModifier(cornerRadius: cornerRadius))
    }
}
