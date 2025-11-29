import SwiftUI

class DashboardViewModel: ObservableObject {
    @Published var totalItems: Int = 0
    @Published var totalSales: Decimal = 0

    private let itemRepository: ItemRepositoryProtocol
    private let salesRepository: SalesRepositoryProtocol

    init(itemRepository: ItemRepositoryProtocol, salesRepository: SalesRepositoryProtocol) {
        self.itemRepository = itemRepository
        self.salesRepository = salesRepository
    }

    func loadData() async {
        // Placeholder logic
        do {
            let items = try await itemRepository.fetchAllItems()
            let sales = try await salesRepository.fetchAllSales()

            await MainActor.run {
                self.totalItems = items.count
                self.totalSales = sales.reduce(0) { $0 + $1.amount }
            }
        } catch {
            print("Error loading dashboard data: \(error)")
        }
    }
}
