import SwiftUI

class AppEnvironment: ObservableObject {
    let itemRepository: ItemRepositoryProtocol
    let salesRepository: SalesRepositoryProtocol
    let purchaseRepository: PurchaseRepositoryProtocol
    let brandRepository: BrandRepositoryProtocol
    let categoryRepository: CategoryRepositoryProtocol
    let imageRepository: ImageRepositoryProtocol

    let analyticsService: AnalyticsServiceProtocol
    let imageService: ImageServiceProtocol

    @Published var hasCompletedOnboarding: Bool

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

        self.itemRepository = ItemRepository()
        self.salesRepository = SalesRepository()
        self.purchaseRepository = PurchaseRepository()
        self.brandRepository = BrandRepository()
        self.categoryRepository = CategoryRepository()
        self.imageRepository = ImageRepository()

        self.analyticsService = AnalyticsService(
            itemRepository: itemRepository, salesRepository: salesRepository)
        self.imageService = ImageService()
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        self.hasCompletedOnboarding = true
    }

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(analyticsService: analyticsService)
    }

    func makeInventoryViewModel() -> InventoryViewModel {
        InventoryViewModel(itemRepository: itemRepository)
    }

    func makeSalesViewModel() -> SalesViewModel {
        SalesViewModel(salesRepository: salesRepository)
    }

    func makePurchasesViewModel() -> PurchasesViewModel {
        PurchasesViewModel(purchaseRepository: purchaseRepository)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel()
    }
}
