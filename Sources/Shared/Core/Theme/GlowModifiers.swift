import SwiftUI

// MARK: - Glow Modifiers

struct NeonGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(opacity), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(opacity * 0.6), radius: radius * 2, x: 0, y: 0)
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
            .background(
                LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
                    .mask(content)
                    .blur(radius: radius)
                    .opacity(opacity)
            )
    }
}

struct AmbientLightModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .background(
                color
                    .blur(radius: radius)
                    .opacity(opacity)
                    .scaleEffect(1.2)
            )
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
    func glassEdge(color: Color = .white, opacity: Double = 0.3) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 12)  // Default, should be overridden by shape if possible, but ViewModifier is generic
                .strokeBorder(
                    LinearGradient(
                        colors: [color.opacity(opacity), color.opacity(0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}
