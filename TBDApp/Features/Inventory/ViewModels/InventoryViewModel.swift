import SwiftUI

class InventoryViewModel: ObservableObject {
    @Published var items: [Item] = []

    private let repository: ItemRepositoryProtocol

    init(repository: ItemRepositoryProtocol) {
        self.repository = repository
    }

    func loadItems() async {
        do {
            let fetchedItems = try await repository.fetchAllItems()
            await MainActor.run {
                self.items = fetchedItems
            }
        } catch {
            print("Error loading items: \(error)")
        }
    }
}
