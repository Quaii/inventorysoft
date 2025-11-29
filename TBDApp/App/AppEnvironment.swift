import SwiftUI

class AppEnvironment: ObservableObject {
    let itemRepository: ItemRepositoryProtocol
    let salesRepository: SalesRepositoryProtocol
    let purchaseRepository: PurchaseRepositoryProtocol

    init() {
        self.itemRepository = ItemRepository()
        self.salesRepository = SalesRepository()
        self.purchaseRepository = PurchaseRepository()
    }

    func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(itemRepository: itemRepository, salesRepository: salesRepository)
    }

    func makeInventoryViewModel() -> InventoryViewModel {
        InventoryViewModel(repository: itemRepository)
    }

    func makeSalesViewModel() -> SalesViewModel {
        SalesViewModel(repository: salesRepository)
    }

    func makePurchasesViewModel() -> PurchasesViewModel {
        PurchasesViewModel(repository: purchaseRepository)
    }

    func makeSettingsViewModel() -> SettingsViewModel {
        SettingsViewModel()
    }
}
