import Combine
import Foundation

class PurchasesViewModel: ObservableObject {
    @Published var purchases: [Purchase] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let purchaseRepository: PurchaseRepositoryProtocol

    init(purchaseRepository: PurchaseRepositoryProtocol) {
        self.purchaseRepository = purchaseRepository
    }

    @MainActor
    func loadPurchases() async {
        isLoading = true
        errorMessage = nil

        do {
            self.purchases = try await purchaseRepository.fetchAllPurchases()
        } catch {
            self.errorMessage = "Failed to load purchases: \(error.localizedDescription)"
        }

        isLoading = false
    }

    @MainActor
    func createPurchase(_ purchase: Purchase) async {
        do {
            try await purchaseRepository.createPurchase(purchase)
            await loadPurchases()
        } catch {
            self.errorMessage = "Failed to create purchase: \(error.localizedDescription)"
        }
    }

    @MainActor
    func deletePurchase(id: UUID) async {
        do {
            try await purchaseRepository.deletePurchase(id: id)
            await loadPurchases()
        } catch {
            self.errorMessage = "Failed to delete purchase: \(error.localizedDescription)"
        }
    }
}
