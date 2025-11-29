import SwiftUI

struct PurchasesListView: View {
    @StateObject var viewModel: PurchasesViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.m) {
                Text("Purchases")
                    .font(theme.typography.headingL)
                    .frame(maxWidth: .infinity, alignment: .leading)

                List(viewModel.purchases) { purchase in
                    HStack {
                        Text(purchase.date.formatted(date: .abbreviated, time: .shortened))
                        Spacer()
                        Text("$\(NSDecimalNumber(decimal: purchase.amount).stringValue)")
                    }
                }
            }
        }
        .task {
            await viewModel.loadPurchases()
        }
    }
}
