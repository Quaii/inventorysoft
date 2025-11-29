import Combine
import Foundation

class InventoryViewModel: ObservableObject {
    @Published var items: [Item] = []
    @Published var searchText: String = ""
    @Published var selectedStatus: ItemStatus?
    @Published var selectedCategory: String?
    @Published var sortOption: ItemSortOption = .byDateAddedDescending
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // Mock categories for now
    let categories = ["Electronics", "Clothing", "Home", "Sports", "Other"]

    private let itemRepository: ItemRepositoryProtocol

    init(itemRepository: ItemRepositoryProtocol) {
        self.itemRepository = itemRepository
    }

    @MainActor
    func loadItems() async {
        isLoading = true
        errorMessage = nil

        do {
            let statusFilter = selectedStatus.map { [$0] }
            self.items = try await itemRepository.fetchAllItems(
                search: searchText, statusFilter: statusFilter, sort: sortOption)
        } catch {
            self.errorMessage = "Failed to load items: \(error.localizedDescription)"
        }

        isLoading = false
    }

    @MainActor
    func deleteItem(id: UUID) async {
        do {
            try await itemRepository.deleteItem(id: id)
            await loadItems()
        } catch {
            self.errorMessage = "Failed to delete item: \(error.localizedDescription)"
        }
    }
}
