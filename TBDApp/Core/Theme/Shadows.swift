import SwiftUI

struct AppShadows {
    let subtle = ShadowStyle(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
    let card = ShadowStyle(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    let elevated = ShadowStyle(color: Color.black.opacity(0.4), radius: 30, x: 0, y: 15)
    let glow = ShadowStyle(color: Color(hex: "3B82F6").opacity(0.2), radius: 20, x: 0, y: 0)  // New glow effect
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
