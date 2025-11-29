import Combine
import Foundation

class SettingsViewModel: ObservableObject {
    @Published var isDarkMode: Bool {
        didSet {
            // Persist setting (mock for now, or use UserDefaults)
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }

    init() {
        self.isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
    }
}
