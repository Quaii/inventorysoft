import Combine
import Foundation
import UniformTypeIdentifiers

@MainActor
class SettingsViewModel: ObservableObject {
    private let userPreferencesRepository: UserPreferencesRepositoryProtocol
    let importProfileRepository: ImportProfileRepositoryProtocol
    let importMappingService: ImportMappingServiceProtocol

    @Published var userPreferences: UserPreferences
    @Published var showingImportMapping = false
    @Published var showingResetConfirmation = false
    @Published var resetConfirmationText = ""
    @Published var importURL: URL?
    @Published var importTargetType: ImportTargetType = .item
    @Published var errorMessage: String?

    init(
        userPreferencesRepository: UserPreferencesRepositoryProtocol,
        importProfileRepository: ImportProfileRepositoryProtocol,
        importMappingService: ImportMappingServiceProtocol
    ) {
        self.userPreferencesRepository = userPreferencesRepository
        self.importProfileRepository = importProfileRepository
        self.importMappingService = importMappingService
        self.userPreferences = .default

        Task {
            await loadPreferences()
        }
    }

    func loadPreferences() async {
        do {
            userPreferences = try await userPreferencesRepository.getPreferences()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func savePreferences() async {
        do {
            try await userPreferencesRepository.savePreferences(userPreferences)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - General Settings

    func updateCurrency(_ currency: String) async {
        userPreferences.baseCurrency = currency
        userPreferences.displayCurrency = currency
        await savePreferences()
    }

    func updateDateFormat(_ format: String) async {
        userPreferences.dateFormat = format
        await savePreferences()
    }

    func updateNumberFormat(_ format: String) async {
        userPreferences.numberFormattingLocale = format
        await savePreferences()
    }

    // MARK: - Appearance Settings

    func updateThemeMode(_ mode: String) async {
        userPreferences.themeMode = mode
        await savePreferences()
    }

    func updateCompactMode(_ enabled: Bool) async {
        userPreferences.compactMode = enabled
        await savePreferences()
    }

    func updateAccentColor(_ color: String) async {
        userPreferences.accentColor = color
        await savePreferences()
    }

    func updateSidebarBehavior(_ behavior: String) async {
        userPreferences.sidebarCollapseBehavior = behavior
        await savePreferences()
    }

    // MARK: - Dashboard & Analytics Settings

    func updateDashboardInitialLayout(_ layout: String) async {
        userPreferences.dashboardInitialLayout = layout
        await savePreferences()
    }

    func updateAllowDashboardEditing(_ allow: Bool) async {
        userPreferences.allowDashboardEditing = allow
        await savePreferences()
    }

    func updateDefaultAnalyticsRange(_ range: String) async {
        userPreferences.defaultAnalyticsRange = range
        await savePreferences()
    }

    func updateDefaultAnalyticsInterval(_ interval: String) async {
        userPreferences.defaultAnalyticsInterval = interval
        await savePreferences()
    }

    // MARK: - Data Management

    func updateBackupLocation(_ path: String) async {
        userPreferences.backupLocationPath = path
        await savePreferences()
    }

    func updateBackupFrequency(_ frequency: String) async {
        userPreferences.backupFrequency = frequency
        await savePreferences()
    }

    func handleImportFile(_ url: URL, targetType: ImportTargetType) {
        self.importURL = url
        self.importTargetType = targetType
        self.showingImportMapping = true
    }

    // NOTE: Export/Import/Backup implementation to be added
    // These will be wired to ExportService and backup functionality
}
