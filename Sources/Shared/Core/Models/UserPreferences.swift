import Foundation

public struct UserPreferences: Codable, Equatable {
    // General Settings
    public var baseCurrency: String
    public var displayCurrency: String
    public var dateFormat: String
    public var numberFormattingLocale: String
    public var firstDayOfWeek: String

    // Appearance Settings
    public var themeMode: String
    public var compactMode: Bool
    public var accentColor: String
    public var sidebarCollapseBehavior: String

    // Dashboard & Analytics Settings
    public var dashboardInitialLayout: String
    public var allowDashboardEditing: Bool
    public var defaultAnalyticsRange: String
    public var defaultAnalyticsInterval: String
    public var hasCustomizedAnalytics: Bool

    // Data Management Settings
    public var backupLocationPath: String
    public var backupFrequency: String

    public init(
        baseCurrency: String = "USD",
        displayCurrency: String = "USD",
        dateFormat: String = "DD/MM/YYYY",
        numberFormattingLocale: String = "System",
        firstDayOfWeek: String = "Sunday",
        themeMode: String = "System",
        compactMode: Bool = false,
        accentColor: String = "Blue",
        sidebarCollapseBehavior: String = "Collapsible",
        hasCustomizedAnalytics: Bool = false,
        dashboardInitialLayout: String = "Recommended KPIs",
        allowDashboardEditing: Bool = true,
        defaultAnalyticsRange: String = "Last 30 Days",
        defaultAnalyticsInterval: String = "Daily",
        backupLocationPath: String = "",
        backupFrequency: String = "Off"
    ) {
        self.baseCurrency = baseCurrency
        self.displayCurrency = displayCurrency
        self.dateFormat = dateFormat
        self.numberFormattingLocale = numberFormattingLocale
        self.firstDayOfWeek = firstDayOfWeek
        self.themeMode = themeMode
        self.compactMode = compactMode
        self.accentColor = accentColor
        self.sidebarCollapseBehavior = sidebarCollapseBehavior
        self.hasCustomizedAnalytics = hasCustomizedAnalytics
        self.dashboardInitialLayout = dashboardInitialLayout
        self.allowDashboardEditing = allowDashboardEditing
        self.defaultAnalyticsRange = defaultAnalyticsRange
        self.defaultAnalyticsInterval = defaultAnalyticsInterval
        self.backupLocationPath = backupLocationPath
        self.backupFrequency = backupFrequency
    }

    public static let `default` = UserPreferences()
}

// Available options
extension UserPreferences {
    public static let availableCurrencies = [
        "USD", "EUR", "GBP", "CHF", "CAD", "AUD", "SEK", "NOK", "DKK", "PLN",
    ]
    public static let availableDateFormats = ["DD/MM/YYYY", "MM/DD/YYYY", "YYYY-MM-DD"]
    public static let availableNumberFormats = ["System", "1,234.56", "1.234,56"]
    public static let availableFirstDayOfWeek = ["Sunday", "Monday"]
    public static let availableThemeModes = ["System", "Light", "Dark"]
    public static let availableAccentColors = ["Blue", "Purple", "Green", "Orange", "Pink", "Gray"]
    public static let availableSidebarBehaviors = ["Collapsible", "Fixed Expanded"]
    public static let availableDashboardLayouts = ["Empty", "Recommended KPIs"]
    public static let availableAnalyticsRanges = [
        "Last 7 Days", "Last 30 Days", "Last 90 Days", "All Time",
    ]
    public static let availableAnalyticsIntervals = ["Daily", "Weekly", "Monthly"]
    public static let availableBackupFrequencies = ["Off", "Daily", "Weekly", "Monthly"]
}
