import Combine
import Foundation
import UniformTypeIdentifiers

@MainActor
class SettingsViewModel: ObservableObject {
    private let userPreferencesRepository: UserPreferencesRepositoryProtocol
    let customFieldRepository: CustomFieldRepositoryProtocol
    let importProfileRepository: ImportProfileRepositoryProtocol
    let importMappingService: ImportMappingServiceProtocol

    @Published var userPreferences: UserPreferences
    @Published var showingCustomFieldManagement = false
    @Published var showingImportMapping = false
    @Published var importURL: URL?
    @Published var importTargetType: ImportTargetType = .item
    @Published var errorMessage: String?

    init(
        userPreferencesRepository: UserPreferencesRepositoryProtocol,
        customFieldRepository: CustomFieldRepositoryProtocol,
        importProfileRepository: ImportProfileRepositoryProtocol,
        importMappingService: ImportMappingServiceProtocol
    ) {
        self.userPreferencesRepository = userPreferencesRepository
        self.customFieldRepository = customFieldRepository
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

    func updateThemeMode(_ mode: String) async {
        userPreferences.themeMode = mode
        await savePreferences()
    }

    func updateCompactMode(_ enabled: Bool) async {
        userPreferences.compactMode = enabled
        await savePreferences()
    }

    func updateStoreName(_ name: String) async {
        // Store in userPreferences if we add a storeName field, or handle separately
        await savePreferences()
    }

    func updateCurrency(_ currency: String) async {
        userPreferences.baseCurrency = currency
        userPreferences.displayCurrency = currency
        await savePreferences()
    }

    func updateDateFormat(_ format: String) async {
        userPreferences.dateFormat = format
        await savePreferences()
    }

    func handleImportFile(_ url: URL, targetType: ImportTargetType) {
        self.importURL = url
        self.importTargetType = targetType
        self.showingImportMapping = true
    }
}
