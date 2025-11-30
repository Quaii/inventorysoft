import Foundation

struct UserPreferences: Codable, Equatable {
    // General Settings
    var baseCurrency: String
    var displayCurrency: String
    var dateFormat: String
    var numberFormattingLocale: String
    var firstDayOfWeek: String

    // Appearance Settings
    var themeMode: String
    var compactMode: Bool
    var accentColor: String
    var sidebarCollapseBehavior: String

    // Dashboard & Analytics Settings
    var dashboardInitialLayout: String
    var allowDashboardEditing: Bool
    var defaultAnalyticsRange: String
    var defaultAnalyticsInterval: String

    // Data Management Settings
    var backupLocationPath: String
    var backupFrequency: String

    init(
        baseCurrency: String = "USD",
        displayCurrency: String = "USD",
        dateFormat: String = "DD/MM/YYYY",
        numberFormattingLocale: String = "System",
        firstDayOfWeek: String = "Sunday",
        themeMode: String = "System",
        compactMode: Bool = false,
        accentColor: String = "Blue",
        sidebarCollapseBehavior: String = "Collapsible",
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
        self.dashboardInitialLayout = dashboardInitialLayout
        self.allowDashboardEditing = allowDashboardEditing
        self.defaultAnalyticsRange = defaultAnalyticsRange
        self.defaultAnalyticsInterval = defaultAnalyticsInterval
        self.backupLocationPath = backupLocationPath
        self.backupFrequency = backupFrequency
    }

    static let `default` = UserPreferences()
}

// Available options
extension UserPreferences {
    static let availableCurrencies = [
        "USD", "EUR", "GBP", "CHF", "CAD", "AUD", "SEK", "NOK", "DKK", "PLN",
    ]
    static let availableDateFormats = ["DD/MM/YYYY", "MM/DD/YYYY", "YYYY-MM-DD"]
    static let availableNumberFormats = ["System", "1,234.56", "1.234,56"]
    static let availableFirstDayOfWeek = ["Sunday", "Monday"]
    static let availableThemeModes = ["System", "Light", "Dark"]
    static let availableAccentColors = ["Blue", "Purple", "Green", "Orange", "Pink", "Gray"]
    static let availableSidebarBehaviors = ["Collapsible", "Fixed Expanded"]
    static let availableDashboardLayouts = ["Empty", "Recommended KPIs"]
    static let availableAnalyticsRanges = [
        "Last 7 Days", "Last 30 Days", "Last 90 Days", "All Time",
    ]
    static let availableAnalyticsIntervals = ["Daily", "Weekly", "Monthly"]
    static let availableBackupFrequencies = ["Off", "Daily", "Weekly", "Monthly"]
}
