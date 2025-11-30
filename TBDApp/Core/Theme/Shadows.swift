import SwiftUI

struct AppShadows {
    // Vinted-style: subtle shadows, no heavy glows
    let card = ShadowStyle(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
    let subtle = ShadowStyle(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
    let elevated = ShadowStyle(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)

    // No glows - keeping it minimal
    let none = ShadowStyle(color: Color.clear, radius: 0, x: 0, y: 0)
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
