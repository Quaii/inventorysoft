import SwiftUI

public struct AppColors {
    // Brand Colors
    public let brandPrimary = Color(hex: "#00D084")
    public let brandSecondary = Color(hex: "#00D084").opacity(0.8)
    public let brandAccent = Color(hex: "#16E091")

    // Surface Colors
    public let backgroundPrimary = Color(hex: "#050505")  // Deepest black
    public let surface0 = Color(hex: "#0D0D0D")  // Base surface
    public let surface1 = Color(hex: "#121212")  // Card background
    public let surface2 = Color(hex: "#181818")  // Hover state
    public let surface3 = Color(hex: "#1E1E1E")  // Active state
    public let surface4 = Color(hex: "#242424")  // Floating elements

    // Legacy/Semantic Aliases
    public var surface: Color { surface1 }
    public var surfaceSecondary: Color { surface2 }
    public var surfaceMuted: Color { surface0 }
    public var surfaceBase: Color { surface0 }
    public var surfaceRow: Color { surface1 }

    // Text Colors
    public let textPrimary = Color(hex: "#FFFFFF")
    public let textSecondary = Color(hex: "#A1A1AA")
    public let textTertiary = Color(hex: "#52525B")
    public var textMuted: Color { textTertiary }

    // Status Colors
    public let success = Color(hex: "#10B981")
    public let warning = Color(hex: "#F59E0B")
    public let error = Color(hex: "#EF4444")
    public let info = Color(hex: "#3B82F6")

    // Stroke/Border Colors
    public let stroke0 = Color(hex: "#FFFFFF").opacity(0.04)
    public let stroke1 = Color(hex: "#FFFFFF").opacity(0.06)
    public let stroke2 = Color(hex: "#FFFFFF").opacity(0.10)
    public let stroke3 = Color(hex: "#FFFFFF").opacity(0.15)

    public init() {}
}

extension Theme {
    public var colors: AppColors {
        AppColors()
    }
}
