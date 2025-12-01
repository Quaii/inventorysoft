import SwiftUI

enum ThemeMode: String, Codable {
    case dark
    case light
    case system

    var displayName: String {
        switch self {
        case .dark: return "Dark"
        case .light: return "Light"
        case .system: return "System"
        }
    }
}

struct AppColors {
    // Backgrounds
    let backgroundPrimary: Color
    let backgroundSecondary: Color
    let backgroundElevated: Color
    let backgroundGlass: Color  // New for glassmorphism

    // Surfaces
    let surfacePrimary: Color
    let surfaceSecondary: Color
    let surfaceMuted: Color
    let surfaceElevated: Color
    let surfaceGlass: Color  // New for glassmorphism

    // Text
    let textPrimary: Color
    let textSecondary: Color
    let textMuted: Color
    let textInversePrimary: Color

    // Accents
    let accentPrimary: Color
    let accentSecondary: Color
    let accentTertiary: Color
    let accentSoft: Color

    // Semantic Accents
    let accentPositive: Color
    let accentNegative: Color
    let accentWarning: Color
    let accentInfo: Color

    // Semantic (Legacy compatibility)
    let success: Color
    let warning: Color
    let error: Color
    let info: Color

    // Borders
    let borderSubtle: Color
    let borderStrong: Color
    let borderHighlight: Color
    let divider: Color
    let buttonBorder: Color

    // States
    let highlight: Color
    let selection: Color
    let focusRing: Color

    // Table Specific
    let tableHeader: Color
    let tableRow: Color
    let sidebarActiveBackground: Color
    let sidebarActiveIndicator: Color

    // Scrollbar
    let scrollbarTrack: Color
    let scrollbarThumb: Color

    init(mode: ThemeMode = .dark) {
        switch mode {
        case .dark, .system:
            // Bare Bone Dark Mode
            self.backgroundPrimary = .black
            self.backgroundSecondary = .black
            self.backgroundElevated = .black
            self.backgroundGlass = .black

            self.surfacePrimary = .black
            self.surfaceSecondary = .black
            self.surfaceMuted = Color(white: 0.1)
            self.surfaceElevated = .black
            self.surfaceGlass = .black

            self.textPrimary = .white
            self.textSecondary = .gray
            self.textMuted = .gray
            self.textInversePrimary = .black

            // Standard Accents
            self.accentPrimary = .blue
            self.accentSecondary = .green
            self.accentTertiary = .purple
            self.accentSoft = .blue

            self.accentPositive = .green
            self.accentNegative = .red
            self.accentWarning = .orange
            self.accentInfo = .blue

            self.success = .green
            self.warning = .orange
            self.error = .red
            self.info = .blue

            self.borderSubtle = Color(white: 0.2)
            self.borderStrong = .gray
            self.borderHighlight = .blue
            self.divider = Color(white: 0.2)
            self.buttonBorder = .gray

            self.highlight = Color(white: 0.2)
            self.selection = .blue
            self.focusRing = .blue

            self.tableHeader = .gray
            self.tableRow = .black
            self.sidebarActiveBackground = .blue
            self.sidebarActiveIndicator = .blue

            self.scrollbarTrack = .clear
            self.scrollbarThumb = .gray

        case .light:
            // Bare Bone Light Mode
            self.backgroundPrimary = .white
            self.backgroundSecondary = .white
            self.backgroundElevated = .white
            self.backgroundGlass = .white

            self.surfacePrimary = .white
            self.surfaceSecondary = .white
            self.surfaceMuted = Color(white: 0.95)
            self.surfaceElevated = .white
            self.surfaceGlass = .white

            self.textPrimary = .black
            self.textSecondary = .gray
            self.textMuted = .gray
            self.textInversePrimary = .white

            // Standard Accents
            self.accentPrimary = .blue
            self.accentSecondary = .green
            self.accentTertiary = .purple
            self.accentSoft = .blue

            self.accentPositive = .green
            self.accentNegative = .red
            self.accentWarning = .orange
            self.accentInfo = .blue

            self.success = .green
            self.warning = .orange
            self.error = .red
            self.info = .blue

            self.borderSubtle = Color(white: 0.9)
            self.borderStrong = .gray
            self.borderHighlight = .blue
            self.divider = Color(white: 0.9)
            self.buttonBorder = .gray

            self.highlight = Color(white: 0.9)
            self.selection = .blue
            self.focusRing = .blue

            self.tableHeader = .gray
            self.tableRow = .white
            self.sidebarActiveBackground = .blue
            self.sidebarActiveIndicator = .blue

            self.scrollbarTrack = .clear
            self.scrollbarThumb = .gray
        }
    }
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
