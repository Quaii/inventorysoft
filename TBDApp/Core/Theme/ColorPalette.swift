import SwiftUI

struct AppColors {
    // Backgrounds
    let backgroundPrimary = Color(hex: "0F1115")  // Deep Charcoal/Graphite
    let backgroundSecondary = Color(hex: "161920")  // Slightly lighter for sidebar/panels
    let backgroundElevated = Color(hex: "1C1F26")  // Card background base

    // Surfaces (Layered darks)
    let surfacePrimary = Color(hex: "1C1F26")  // Main card surface
    let surfaceSecondary = Color(hex: "252932")  // Input fields, inner containers
    let surfaceMuted = Color(hex: "161920").opacity(0.5)
    let surfaceElevated = Color(hex: "2D3340")  // Hover states, dropdowns

    // Text
    let textPrimary = Color(hex: "FFFFFF")
    let textSecondary = Color(hex: "9CA3AF")  // Cool gray (Tailwind gray-400 equivalent)
    let textMuted = Color(hex: "6B7280")  // Tailwind gray-500
    let textInversePrimary = Color(hex: "0F1115")

    // Accents
    let accentPrimary = Color(hex: "3B82F6")  // Electric Blue
    let accentSecondary = Color(hex: "8B5CF6")  // Vivid Purple
    let accentTertiary = Color(hex: "F59E0B")  // Warm Orange/Amber (from inspiration)
    let accentSoft = Color(hex: "3B82F6").opacity(0.15)  // Soft blue glow

    // Semantic
    let success = Color(hex: "10B981")  // Emerald
    let warning = Color(hex: "F59E0B")  // Amber
    let error = Color(hex: "EF4444")  // Red
    let info = Color(hex: "0EA5E9")  // Sky

    // Borders
    let borderSubtle = Color(hex: "FFFFFF").opacity(0.08)
    let borderStrong = Color(hex: "FFFFFF").opacity(0.15)
    let borderHighlight = Color(hex: "FFFFFF").opacity(0.05)  // Top highlight for cards

    // States
    let highlight = Color(hex: "FFFFFF").opacity(0.05)
    let selection = Color(hex: "3B82F6").opacity(0.2)
    let focusRing = Color(hex: "3B82F6")

    init() {}
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
