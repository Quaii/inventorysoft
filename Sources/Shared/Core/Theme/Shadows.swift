import SwiftUI

struct AppShadows {
    // Bare bone - no shadows
    let card = ShadowStyle(color: Color.clear, radius: 0, x: 0, y: 0)
    let subtle = ShadowStyle(color: Color.clear, radius: 0, x: 0, y: 0)
    let elevated = ShadowStyle(color: Color.clear, radius: 0, x: 0, y: 0)

    // Advanced Depth - Disabled
    let softFloating = ShadowStyle(color: Color.clear, radius: 0, x: 0, y: 0)
    let deepFloating = ShadowStyle(color: Color.clear, radius: 0, x: 0, y: 0)

    // Glows - Disabled
    let neonGlow = ShadowStyle(color: Color.clear, radius: 0, x: 0, y: 0)

    let none = ShadowStyle(color: Color.clear, radius: 0, x: 0, y: 0)
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
