import SwiftUI

struct AppShadows {
    let subtle = ShadowStyle(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    let card = ShadowStyle(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    let elevated = ShadowStyle(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
}

struct ShadowStyle {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}
