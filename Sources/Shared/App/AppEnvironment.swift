import GRDB
import SwiftUI

public final class AppEnvironment: ObservableObject {
    public let itemRepository: ItemRepositoryProtocol
    public let salesRepository: SalesRepositoryProtocol
    public let purchaseRepository: PurchaseRepositoryProtocol
    public let brandRepository: BrandRepositoryProtocol
    public let categoryRepository: CategoryRepositoryProtocol
    public let imageRepository: ImageRepositoryProtocol
    public let customFieldRepository: CustomFieldRepositoryProtocol
    public let userPreferencesRepository: UserPreferencesRepositoryProtocol
    public let dashboardConfigRepository: DashboardConfigRepositoryProtocol
    public let columnConfigRepository: ColumnConfigRepositoryProtocol
    public let importProfileRepository: ImportProfileRepositoryProtocol
    public let analyticsConfigRepository: AnalyticsConfigRepositoryProtocol
    public let analyticsWidgetRepository: AnalyticsWidgetRepositoryProtocol

    public let analyticsService: AnalyticsServiceProtocol
    public let imageService: ImageServiceProtocol
    public let dashboardConfigService: DashboardConfigServiceProtocol
    public let columnConfigService: ColumnConfigServiceProtocol
    public let importMappingService: ImportMappingServiceProtocol
    public let analyticsConfigService: AnalyticsConfigServiceProtocol
    public let analyticsConfigService: AnalyticsConfigServiceProtocol
    public let exportService: ExportService
    public let kpiService: KPIServiceProtocol

    @Published public var hasCompletedOnboarding: Bool
    @Published public var userPreferences: UserPreferences
    @Published public var currentTheme: Theme

    public init() {
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
        self.analyticsConfigRepository = AnalyticsConfigRepository(
            dbQueue: DatabaseManager.shared.dbWriter as! GRDB.DatabaseQueue)
        self.analyticsWidgetRepository = AnalyticsWidgetRepository()

        self.analyticsService = AnalyticsService(
            itemRepository: itemRepository, salesRepository: salesRepository)
        self.imageService = ImageService()
        self.dashboardConfigService = DashboardConfigService(repository: dashboardConfigRepository)
        self.columnConfigService = ColumnConfigService(repository: columnConfigRepository)
        self.importMappingService = ImportMappingService()
        self.analyticsConfigService = AnalyticsConfigService(
            repository: analyticsConfigRepository,
            preferencesRepo: userPreferencesRepository
        )
        self.exportService = ExportService(
            db: DatabaseManager.shared, columnConfigService: columnConfigService)
        self.kpiService = KPIService(analyticsService: analyticsService)

        // Load user preferences
        self.userPreferences = .default
        self.currentTheme = Theme()

        Task {
            do {
                let prefs = try await userPreferencesRepository.getPreferences()
                await MainActor.run {
                    self.userPreferences = prefs
                    self.updateTheme(from: prefs)
                }
            } catch {
                print("Error loading user preferences: \(error)")
            }
        }
    }

    public func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        self.hasCompletedOnboarding = true
    }

    @MainActor
    public func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            dashboardConfigService: dashboardConfigService,
            analyticsService: analyticsService,
            kpiService: kpiService,
            inventoryViewModel: makeInventoryViewModel(),
            salesViewModel: makeSalesViewModel(),
            purchasesViewModel: makePurchasesViewModel()
        )
    }

    public func makeInventoryViewModel() -> InventoryViewModel {
        InventoryViewModel(
            itemRepository: itemRepository,
            columnConfigService: columnConfigService,
            customFieldRepository: customFieldRepository
        )
    }

    public func makeSalesViewModel() -> SalesViewModel {
        SalesViewModel(
            salesRepository: salesRepository,
            columnConfigService: columnConfigService,
            customFieldRepository: customFieldRepository
        )
    }

    public func makePurchasesViewModel() -> PurchasesViewModel {
        PurchasesViewModel(
            purchaseRepository: purchaseRepository,
            columnConfigService: columnConfigService,
            customFieldRepository: customFieldRepository
        )
    }

    @MainActor
    public func makeAnalyticsViewModel() -> AnalyticsViewModel {
        AnalyticsViewModel(
            widgetRepository: analyticsWidgetRepository,
            analyticsService: analyticsService,
            configService: analyticsConfigService,
            exportService: exportService
        )
    }

    @MainActor
    public func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel(
            userPreferencesRepository: userPreferencesRepository,
            importProfileRepository: importProfileRepository,
            importMappingService: importMappingService
        )
    }

    public func makeItemDetailViewModel() -> ItemDetailViewModel {
        ItemDetailViewModel(
            itemRepository: itemRepository,
            imageRepository: imageRepository,
            imageService: imageService,
            salesRepository: salesRepository
        )
    }

    public func savePreferences(_ preferences: UserPreferences) async throws {
        try await userPreferencesRepository.savePreferences(preferences)
        await MainActor.run {
            self.userPreferences = preferences
            self.updateTheme(from: preferences)
        }
    }

    // MARK: - Theme Management

    @MainActor
    private func updateTheme(from preferences: UserPreferences) {
        _ = ThemeMode(rawValue: preferences.themeMode.lowercased()) ?? .dark
        self.currentTheme = Theme()
    }
}
