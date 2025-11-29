import SwiftUI

struct Theme {
    let colors: AppColors
    let typography: AppTypography
    let spacing: AppSpacing
    let radii: AppCornerRadius
    let shadows: AppShadows

    static let standard = Theme(
        colors: AppColors(),
        typography: AppTypography(),
        spacing: AppSpacing(),
        radii: AppCornerRadius(),
        shadows: AppShadows()
    )
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
