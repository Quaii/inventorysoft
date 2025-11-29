import Combine
import Foundation

class SettingsViewModel: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

    @Published var username: String = "User"
    @Published var email: String = "user@example.com"
    @Published var notificationsEnabled: Bool = true
    @Published var selectedCurrency: String = "USD"

    let currencies = ["USD", "EUR", "GBP", "JPY"]

    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
}
