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

    init() {
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
