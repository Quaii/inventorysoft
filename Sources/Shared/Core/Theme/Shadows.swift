import SwiftUI

struct AppShadows {
    // Subtle shadows for professional macOS design
    let card = ShadowStyle(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 4)
    let subtle = ShadowStyle(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
    let elevated = ShadowStyle(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)

    // Advanced Depth
    let softFloating = ShadowStyle(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    let deepFloating = ShadowStyle(color: Color.black.opacity(0.5), radius: 30, x: 0, y: 15)

    // Glows (Base tokens, use modifiers for complex effects)
    let neonGlow = ShadowStyle(color: Color.green.opacity(0.5), radius: 15, x: 0, y: 0)

    let none = ShadowStyle(color: Color.clear, radius: 0, x: 0, y: 0)
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
