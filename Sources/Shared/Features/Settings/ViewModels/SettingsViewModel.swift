import Combine
import Foundation
import UniformTypeIdentifiers

@MainActor
public class SettingsViewModel: ObservableObject {
    private let userPreferencesRepository: UserPreferencesRepositoryProtocol
    public let importProfileRepository: ImportProfileRepositoryProtocol
    public let importMappingService: ImportMappingServiceProtocol

    @Published public var userPreferences: UserPreferences
    @Published public var showingImportMapping = false
    @Published public var showingResetConfirmation = false
    @Published public var resetConfirmationText = ""
    @Published public var importURL: URL?
    @Published public var importTargetType: ImportTargetType = .item
    @Published public var errorMessage: String?

    public init(
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

    public func loadPreferences() async {
        do {
            userPreferences = try await userPreferencesRepository.getPreferences()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func savePreferences() async {
        do {
            try await userPreferencesRepository.savePreferences(userPreferences)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - General Settings

    public func updateCurrency(_ currency: String) async {
        userPreferences.baseCurrency = currency
        userPreferences.displayCurrency = currency
        await savePreferences()
    }

    public func updateDateFormat(_ format: String) async {
        userPreferences.dateFormat = format
        await savePreferences()
    }

    public func updateNumberFormat(_ format: String) async {
        userPreferences.numberFormattingLocale = format
        await savePreferences()
    }

    // MARK: - Appearance Settings

    public func updateThemeMode(_ mode: String) async {
        userPreferences.themeMode = mode
        await savePreferences()
    }

    public func updateCompactMode(_ enabled: Bool) async {
        userPreferences.compactMode = enabled
        await savePreferences()
    }

    public func updateAccentColor(_ color: String) async {
        userPreferences.accentColor = color
        await savePreferences()
    }

    public func updateSidebarBehavior(_ behavior: String) async {
        userPreferences.sidebarCollapseBehavior = behavior
        await savePreferences()
    }

    // MARK: - Dashboard & Analytics Settings

    public func updateDashboardInitialLayout(_ layout: String) async {
        userPreferences.dashboardInitialLayout = layout
        await savePreferences()
    }

    public func updateAllowDashboardEditing(_ allow: Bool) async {
        userPreferences.allowDashboardEditing = allow
        await savePreferences()
    }

    public func updateDefaultAnalyticsRange(_ range: String) async {
        userPreferences.defaultAnalyticsRange = range
        await savePreferences()
    }

    public func updateDefaultAnalyticsInterval(_ interval: String) async {
        userPreferences.defaultAnalyticsInterval = interval
        await savePreferences()
    }

    // MARK: - Data Management

    public func updateBackupLocation(_ path: String) async {
        userPreferences.backupLocationPath = path
        await savePreferences()
    }

    public func updateBackupFrequency(_ frequency: String) async {
        userPreferences.backupFrequency = frequency
        await savePreferences()
    }

    public func handleImportFile(_ url: URL, targetType: ImportTargetType) {
        self.importURL = url
        self.importTargetType = targetType
        self.showingImportMapping = true
    }

    // NOTE: Export/Import/Backup implementation to be added
    // These will be wired to ExportService and backup functionality
}
