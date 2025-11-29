import SwiftUI

class PurchasesViewModel: ObservableObject {
    @Published var purchases: [Purchase] = []

    private let repository: PurchaseRepositoryProtocol

    init(repository: PurchaseRepositoryProtocol) {
        self.repository = repository
    }

    func loadPurchases() async {
        do {
            let fetchedPurchases = try await repository.fetchAllPurchases()
            await MainActor.run {
                self.purchases = fetchedPurchases
            }
        } catch {
            print("Error loading purchases: \(error)")
        }
    }
}
