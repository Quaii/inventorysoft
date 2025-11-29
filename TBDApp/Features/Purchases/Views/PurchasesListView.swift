import SwiftUI

struct PurchasesListView: View {
    @StateObject var viewModel: PurchasesViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.m) {
                HStack {
                    Text("Purchases")
                        .font(theme.typography.h2)
                        .foregroundColor(theme.colors.textPrimary)
                    Spacer()
                    AppButton(title: "Add Purchase", icon: "plus", style: .primary) {
                        // Add purchase action
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(theme.colors.error)
                } else {
                    AppTable(viewModel.purchases) { purchase in
                        HStack {
                            Text(
                                purchase.datePurchased.formatted(date: .abbreviated, time: .omitted)
                            )
                            .font(theme.typography.bodyM)
                            .frame(width: 100, alignment: .leading)

                            Text(purchase.supplier)
                                .font(theme.typography.bodyM)
                                .frame(width: 150, alignment: .leading)

                            Spacer()

                            Text(purchase.cost.formatted(.currency(code: "USD")))
                                .font(theme.typography.bodyM)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, theme.spacing.s)
                    }
                }
            }
        }
        .task {
            await viewModel.loadPurchases()
        }
    }
}
