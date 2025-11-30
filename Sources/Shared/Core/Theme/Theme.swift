import SwiftUI

/// Layout constants for consistent spacing and sizing across the application
struct AppLayoutConstants {
    // MARK: - Padding
    let horizontalPadding: CGFloat = 28
    let horizontalPaddingCompact: CGFloat = 16

    // MARK: - Spacing
    let sectionSpacing: CGFloat = 24
    let cardSpacing: CGFloat = 16
    let cardSpacingCompact: CGFloat = 12

    // MARK: - Card Heights
    let kpiCardHeight: CGFloat = 120
    let alertCardMinHeight: CGFloat = 80
    let quickListCardHeight: CGFloat = 240
    let analyticsChartCardHeight: CGFloat = 280

    // MARK: - Grid Columns
    let gridColumnMinWidth: CGFloat = 320
    let gridColumnMaxWidth: CGFloat = 500
    let kpiCardMinWidth: CGFloat = 200
    let kpiCardMaxWidth: CGFloat = 400
}

struct Theme {
    let colors: AppColors
    let typography: AppTypography
    let spacing: AppSpacing
    let radii: AppCornerRadius
    let shadows: AppShadows
    let layout: AppLayoutConstants
    let zIndex: AppZIndex

    init(mode: ThemeMode = .dark, compactMode: Bool = false) {
        self.colors = AppColors(mode: mode)
        self.typography = AppTypography()
        self.spacing = AppSpacing(compactMode: compactMode)
        self.radii = AppCornerRadius()
        self.shadows = AppShadows()
        self.layout = AppLayoutConstants()
        self.zIndex = AppZIndex()
    }

    static let standard = Theme(mode: .dark, compactMode: false)

    static func from(mode: ThemeMode, compactMode: Bool) -> Theme {
        return Theme(mode: mode, compactMode: compactMode)
    }
}

struct AppThemeKey: EnvironmentKey {
    static let defaultValue: Theme = .standard
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[AppThemeKey.self] }
        set { self[AppThemeKey.self] = newValue }
    }
}
