import SwiftUI

// MARK: - Icon Modifiers

struct ThinIconModifier: ViewModifier {
    let size: CGFloat

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: .light))
    }
}

struct IconGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(opacity), radius: radius, x: 0, y: 0)
    }
}

// MARK: - View Extensions

extension View {
    /// Applies a thin weight style to the icon (SF Symbol)
    func thinIcon(size: CGFloat = 20) -> some View {
        modifier(ThinIconModifier(size: size))
    }

    /// Applies a specific glow for icons, usually subtle
    func iconGlow(color: Color, radius: CGFloat = 8, opacity: Double = 0.6) -> some View {
        modifier(IconGlowModifier(color: color, radius: radius, opacity: opacity))
    }
}
