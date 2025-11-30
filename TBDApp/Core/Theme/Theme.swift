import SwiftUI

struct Theme {
    let colors: AppColors
    let typography: AppTypography
    let spacing: AppSpacing
    let radii: AppCornerRadius
    let shadows: AppShadows

    init(mode: ThemeMode = .dark, compactMode: Bool = false) {
        self.colors = AppColors(mode: mode)
        self.typography = AppTypography()
        self.spacing = AppSpacing(compactMode: compactMode)
        self.radii = AppCornerRadius()
        self.shadows = AppShadows()
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
