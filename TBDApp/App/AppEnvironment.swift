import SwiftUI

class AppEnvironment: ObservableObject {
    let itemRepository: ItemRepositoryProtocol
    let salesRepository: SalesRepositoryProtocol
    let purchaseRepository: PurchaseRepositoryProtocol
    let brandRepository: BrandRepositoryProtocol
    let categoryRepository: CategoryRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol
    let customFieldRepository: CustomFieldRepositoryProtocol
    let userPreferencesRepository: UserPreferencesRepositoryProtocol
    let dashboardConfigRepository: DashboardConfigRepositoryProtocol
    let columnConfigRepository: ColumnConfigRepositoryProtocol
    let importProfileRepository: ImportProfileRepositoryProtocol

    let analyticsService: AnalyticsServiceProtocol
    let imageService: ImageServiceProtocol
    let dashboardConfigService: DashboardConfigServiceProtocol
    let columnConfigService: ColumnConfigServiceProtocol
    let importMappingService: ImportMappingServiceProtocol
    let exportService: ExportService

    @Published var hasCompletedOnboarding: Bool
    @Published var userPreferences: UserPreferences

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        self.itemRepository = ItemRepository()
        self.salesRepository = SalesRepository()
        self.purchaseRepository = PurchaseRepository()
        self.brandRepository = BrandRepository()
        self.categoryRepository = CategoryRepository()
        self.imageRepository = ImageRepository()
        self.customFieldRepository = CustomFieldRepository()
        self.userPreferencesRepository = UserPreferencesRepository()
        self.dashboardConfigRepository = DashboardConfigRepository()
        self.columnConfigRepository = ColumnConfigRepository()
        self.importProfileRepository = ImportProfileRepository()

        self.analyticsService = AnalyticsService(
            itemRepository: itemRepository, salesRepository: salesRepository)
        self.imageService = ImageService()
        self.dashboardConfigService = DashboardConfigService(repository: dashboardConfigRepository)
        self.columnConfigService = ColumnConfigService(repository: columnConfigRepository)
        self.importMappingService = ImportMappingService()
        self.exportService = ExportService(
            db: DatabaseManager.shared, columnConfigService: columnConfigService)

        // Load user preferences
        self.userPreferences = .default
        Task {
            do {
                let prefs = try await userPreferencesRepository.getPreferences()
                await MainActor.run {
                    self.userPreferences = prefs
                }
            } catch {
                print("Error loading user preferences: \(error)")
            }
        }
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        self.hasCompletedOnboarding = true
    }

    @MainActor
    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            analyticsService: analyticsService,
            dashboardConfigService: dashboardConfigService
        )
    }

    func makeInventoryViewModel() -> InventoryViewModel {
        InventoryViewModel(
            itemRepository: itemRepository,
            columnConfigService: columnConfigService,
            customFieldRepository: customFieldRepository
        )
    }

    func makeSalesViewModel() -> SalesViewModel {
        SalesViewModel(
            salesRepository: salesRepository,
            columnConfigService: columnConfigService,
            customFieldRepository: customFieldRepository
        )
    }

    func makePurchasesViewModel() -> PurchasesViewModel {
        PurchasesViewModel(
            purchaseRepository: purchaseRepository,
            columnConfigService: columnConfigService,
            customFieldRepository: customFieldRepository
        )
    }

    @MainActor
    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            userPreferencesRepository: userPreferencesRepository,
            customFieldRepository: customFieldRepository,
            importProfileRepository: importProfileRepository,
            importMappingService: importMappingService
        )
    }

    func savePreferences(_ preferences: UserPreferences) async throws {
        try await userPreferencesRepository.savePreferences(preferences)
        await MainActor.run {
            self.userPreferences = preferences
        }
    }
}
