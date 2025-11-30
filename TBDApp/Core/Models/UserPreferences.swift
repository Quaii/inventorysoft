import Foundation

struct UserPreferences: Codable, Equatable {
    var baseCurrency: String
    var displayCurrency: String
    var dateFormat: String
    var firstDayOfWeek: String
    var themeMode: String
    var compactMode: Bool
    var accentColor: String

    init(
        baseCurrency: String = "USD",
        displayCurrency: String = "USD",
        dateFormat: String = "MM/DD/YYYY",
        firstDayOfWeek: String = "Sunday",
        themeMode: String = "Dark",
        compactMode: Bool = false,
        accentColor: String = "default"
    ) {
        self.baseCurrency = baseCurrency
        self.displayCurrency = displayCurrency
        self.dateFormat = dateFormat
        self.firstDayOfWeek = firstDayOfWeek
        self.themeMode = themeMode
        self.compactMode = compactMode
        self.accentColor = accentColor
    }

    static let `default` = UserPreferences()
}

// Available options
extension UserPreferences {
    static let availableCurrencies = ["USD", "EUR", "GBP", "JPY", "CAD", "AUD", "CHF", "CNY"]
    static let availableDateFormats = ["MM/DD/YYYY", "DD/MM/YYYY", "YYYY-MM-DD"]
    static let availableFirstDayOfWeek = ["Sunday", "Monday"]
    static let availableThemeModes = ["Dark", "Light", "System"]
    static let availableAccentColors = ["default", "blue", "purple", "green", "orange", "red"]
}
