import Combine
import Foundation

class SalesViewModel: ObservableObject {
    @Published var sales: [Sale] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var searchText: String = ""

    private let salesRepository: SalesRepositoryProtocol
    let columnConfigService: ColumnConfigServiceProtocol
    private let customFieldRepository: CustomFieldRepositoryProtocol

    init(
        salesRepository: SalesRepositoryProtocol,
        columnConfigService: ColumnConfigServiceProtocol,
        customFieldRepository: CustomFieldRepositoryProtocol
    ) {
        self.salesRepository = salesRepository
        self.columnConfigService = columnConfigService
        self.customFieldRepository = customFieldRepository
    }

    @MainActor
    func loadSales() async {
        isLoading = true
        errorMessage = nil

        do {
            self.sales = try await salesRepository.fetchAllSales()
        } catch {
            self.errorMessage = "Failed to load sales: \(error.localizedDescription)"
        }

        isLoading = false
    }

    @MainActor
    func createSale(_ sale: Sale) async {
        do {
            try await salesRepository.createSale(sale)
            await loadSales()
        } catch {
            self.errorMessage = "Failed to create sale: \(error.localizedDescription)"
        }
    }

    @MainActor
    func deleteSale(id: UUID) async {
        do {
            try await salesRepository.deleteSale(id: id)
            await loadSales()
        } catch {
            self.errorMessage = "Failed to delete sale: \(error.localizedDescription)"
        }
    }
}
