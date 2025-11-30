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
            // Visual Overhaul 2.0 (True Black & Neon)
            self.backgroundPrimary = Color(hex: "000000")  // True Black
            self.backgroundSecondary = Color(hex: "050505")  // Deepest Gray
            self.backgroundElevated = Color(hex: "0A0A0A")
            self.backgroundGlass = Color(hex: "000000").opacity(0.6)  // More translucent

            self.surfacePrimary = Color(hex: "0A0A0A")
            self.surfaceSecondary = Color(hex: "121212")
            self.surfaceMuted = Color(hex: "000000").opacity(0.8)
            self.surfaceElevated = Color(hex: "141414")
            self.surfaceGlass = Color(hex: "141414").opacity(0.5)  // High blur glass

            self.textPrimary = Color(hex: "FFFFFF")
            self.textSecondary = Color(hex: "B0B0B0")  // Slightly brighter for contrast
            self.textMuted = Color(hex: "666666")
            self.textInversePrimary = Color(hex: "000000")

            // Neon Accents
            self.accentPrimary = Color(hex: "FFFFFF")  // Keep white for sharp contrast
            self.accentSecondary = Color(hex: "00FF94")  // Cyber Green
            self.accentTertiary = Color(hex: "FF00FF")  // Hot Pink
            self.accentSoft = Color(hex: "FFFFFF").opacity(0.08)

            self.accentPositive = Color(hex: "00FF94")  // Neon Green
            self.accentNegative = Color(hex: "FF3B30")  // Bright Red
            self.accentWarning = Color(hex: "FFCC00")  // Bright Yellow
            self.accentInfo = Color(hex: "00A8FF")  // Electric Blue

            self.success = Color(hex: "00FF94")
            self.warning = Color(hex: "FFCC00")
            self.error = Color(hex: "FF3B30")
            self.info = Color(hex: "00A8FF")

            self.borderSubtle = Color(hex: "1A1A1A")
            self.borderStrong = Color(hex: "333333")
            self.borderHighlight = Color(hex: "FFFFFF").opacity(0.15)
            self.divider = Color(hex: "111111")
            self.buttonBorder = Color(hex: "222222")

            self.highlight = Color(hex: "FFFFFF").opacity(0.1)
            self.selection = Color(hex: "00FF94").opacity(0.15)
            self.focusRing = Color(hex: "00FF94").opacity(0.5)

            self.tableHeader = Color(hex: "888888")
            self.tableRow = Color(hex: "050505")
            self.sidebarActiveBackground = Color(hex: "FFFFFF").opacity(0.1)
            self.sidebarActiveIndicator = Color(hex: "00FF94")

            self.scrollbarTrack = Color.clear
            self.scrollbarThumb = Color(hex: "333333")

        case .light:
            // Clean Light Mode (Minimalist)
            self.backgroundPrimary = Color(hex: "FFFFFF")
            self.backgroundSecondary = Color(hex: "F9F9F9")
            self.backgroundElevated = Color(hex: "FFFFFF")
            self.backgroundGlass = Color(hex: "FFFFFF").opacity(0.9)

            self.surfacePrimary = Color(hex: "FFFFFF")
            self.surfaceSecondary = Color(hex: "F5F5F5")
            self.surfaceMuted = Color(hex: "F0F0F0")
            self.surfaceElevated = Color(hex: "FFFFFF")
            self.surfaceGlass = Color(hex: "FFFFFF").opacity(0.8)

            self.textPrimary = Color(hex: "111111")
            self.textSecondary = Color(hex: "666666")
            self.textMuted = Color(hex: "999999")
            self.textInversePrimary = Color(hex: "FFFFFF")

            self.accentPrimary = Color(hex: "111111")
            self.accentSecondary = Color(hex: "2ECC71")
            self.accentTertiary = Color(hex: "F1C40F")
            self.accentSoft = Color(hex: "000000").opacity(0.05)

            self.accentPositive = Color(hex: "27AE60")
            self.accentNegative = Color(hex: "E74C3C")
            self.accentWarning = Color(hex: "F39C12")
            self.accentInfo = Color(hex: "3498DB")

            self.success = Color(hex: "2ECC71")
            self.warning = Color(hex: "F1C40F")
            self.error = Color(hex: "E74C3C")
            self.info = Color(hex: "3498DB")

            self.borderSubtle = Color(hex: "E5E5E5")
            self.borderStrong = Color(hex: "DDDDDD")
            self.borderHighlight = Color.clear
            self.divider = Color(hex: "EEEEEE")
            self.buttonBorder = Color(hex: "E0E0E0")

            self.highlight = Color(hex: "000000").opacity(0.03)
            self.selection = Color(hex: "000000").opacity(0.05)
            self.focusRing = Color(hex: "000000").opacity(0.1)

            self.tableHeader = Color(hex: "666666")
            self.tableRow = Color(hex: "FFFFFF")
            self.sidebarActiveBackground = Color(hex: "000000").opacity(0.05)
            self.sidebarActiveIndicator = Color(hex: "111111")

            self.scrollbarTrack = Color.clear
            self.scrollbarThumb = Color(hex: "CCCCCC")
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
