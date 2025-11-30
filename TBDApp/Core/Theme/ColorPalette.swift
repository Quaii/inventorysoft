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

    // Surfaces
    let surfacePrimary: Color
    let surfaceSecondary: Color
    let surfaceMuted: Color
    let surfaceElevated: Color

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
            // Dark Mode Colors (Vinted Notify style)
            self.backgroundPrimary = Color(hex: "050506")
            self.backgroundSecondary = Color(hex: "080808")
            self.backgroundElevated = Color(hex: "101010")

            self.surfacePrimary = Color(hex: "101010")
            self.surfaceSecondary = Color(hex: "141414")
            self.surfaceMuted = Color(hex: "000000").opacity(0.5)
            self.surfaceElevated = Color(hex: "141414")

            self.textPrimary = Color(hex: "F6F6F6")
            self.textSecondary = Color(hex: "A8A8A8")
            self.textMuted = Color(hex: "6E6E6E")
            self.textInversePrimary = Color(hex: "101010")

            self.accentPrimary = Color(hex: "FFFFFF")
            self.accentSecondary = Color(hex: "3DDC97")
            self.accentTertiary = Color(hex: "F2A93B")
            self.accentSoft = Color(hex: "FFFFFF").opacity(0.1)

            self.accentPositive = Color(hex: "27AE60")
            self.accentNegative = Color(hex: "E74C3C")
            self.accentWarning = Color(hex: "F39C12")
            self.accentInfo = Color(hex: "3498DB")

            self.success = Color(hex: "3DDC97")
            self.warning = Color(hex: "F2A93B")
            self.error = Color(hex: "F15B5B")
            self.info = Color(hex: "FFFFFF")

            self.borderSubtle = Color(hex: "202020")
            self.borderStrong = Color(hex: "FFFFFF").opacity(0.2)
            self.borderHighlight = Color.clear
            self.divider = Color(hex: "1B1B1B")
            self.buttonBorder = Color(hex: "2A2A2A")

            self.highlight = Color(hex: "FFFFFF").opacity(0.05)
            self.selection = Color(hex: "FFFFFF").opacity(0.1)
            self.focusRing = Color(hex: "FFFFFF").opacity(0.3)

            self.tableHeader = Color(hex: "C0C0C0")
            self.tableRow = Color(hex: "121212")
            self.sidebarActiveBackground = Color(hex: "FFFFFF").opacity(0.1)
            self.sidebarActiveIndicator = Color(hex: "FFFFFF")

            self.scrollbarTrack = Color(hex: "080808")
            self.scrollbarThumb = Color(hex: "202020")

        case .light:
            // Light Mode Colors
            self.backgroundPrimary = Color(hex: "FAFAFA")
            self.backgroundSecondary = Color(hex: "F5F5F5")
            self.backgroundElevated = Color(hex: "FFFFFF")

            self.surfacePrimary = Color(hex: "FFFFFF")
            self.surfaceSecondary = Color(hex: "F8F8F8")
            self.surfaceMuted = Color(hex: "FFFFFF").opacity(0.5)
            self.surfaceElevated = Color(hex: "F5F5F5")

            self.textPrimary = Color(hex: "1A1A1A")
            self.textSecondary = Color(hex: "6B6B6B")
            self.textMuted = Color(hex: "9E9E9E")
            self.textInversePrimary = Color(hex: "FFFFFF")

            self.accentPrimary = Color(hex: "1A1A1A")
            self.accentSecondary = Color(hex: "3DDC97")
            self.accentTertiary = Color(hex: "F2A93B")
            self.accentSoft = Color(hex: "000000").opacity(0.05)

            self.accentPositive = Color(hex: "27AE60")
            self.accentNegative = Color(hex: "E74C3C")
            self.accentWarning = Color(hex: "F39C12")
            self.accentInfo = Color(hex: "3498DB")

            self.success = Color(hex: "3DDC97")
            self.warning = Color(hex: "F2A93B")
            self.error = Color(hex: "F15B5B")
            self.info = Color(hex: "1A1A1A")

            self.borderSubtle = Color(hex: "E5E5E5")
            self.borderStrong = Color(hex: "000000").opacity(0.15)
            self.borderHighlight = Color.clear
            self.divider = Color(hex: "EBEBEB")
            self.buttonBorder = Color(hex: "D4D4D4")

            self.highlight = Color(hex: "000000").opacity(0.03)
            self.selection = Color(hex: "000000").opacity(0.08)
            self.focusRing = Color(hex: "000000").opacity(0.2)

            self.tableHeader = Color(hex: "4A4A4A")
            self.tableRow = Color(hex: "FAFAFA")
            self.sidebarActiveBackground = Color(hex: "000000").opacity(0.08)
            self.sidebarActiveIndicator = Color(hex: "1A1A1A")

            self.scrollbarTrack = Color(hex: "F5F5F5")
            self.scrollbarThumb = Color(hex: "D0D0D0")
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
