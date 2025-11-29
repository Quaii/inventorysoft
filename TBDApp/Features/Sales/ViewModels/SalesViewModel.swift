import SwiftUI

class SalesViewModel: ObservableObject {
    @Published var sales: [Sale] = []

    private let repository: SalesRepositoryProtocol

    init(repository: SalesRepositoryProtocol) {
        self.repository = repository
    }

    func loadSales() async {
        do {
            let fetchedSales = try await repository.fetchAllSales()
            await MainActor.run {
                self.sales = fetchedSales
            }
        } catch {
            print("Error loading sales: \(error)")
        }
    }
}
