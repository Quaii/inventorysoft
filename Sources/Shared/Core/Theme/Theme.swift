import SwiftUI

public struct Theme {
    // Minimal theme definition
    // We can keep accent color if needed, or just rely on system defaults.
    static let accentColor = Color.blue
}

public enum ThemeMode: String, CaseIterable, Codable {
    case system
    case light
    case dark
}

// Environment key for Theme (to be removed eventually, but keeping for now to avoid massive breakage before refactoring views)
struct ThemeKey: EnvironmentKey {
    static let defaultValue = Theme()
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}
