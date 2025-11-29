import SwiftUI

struct PurchasesListView: View {
    @StateObject var viewModel: PurchasesViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.xl) {
                // Header
                HStack {
                    Text("Purchases")
                        .font(theme.typography.headingXL)
                        .foregroundColor(theme.colors.textPrimary)
                    Spacer()
                    AppButton(title: "New Purchase", icon: "plus", style: .primary) {
                        // Navigate to new purchase
                    }
                }

                // Content
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    AppTable(viewModel.purchases) { purchase in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(purchase.supplier)
                                    .font(theme.typography.bodyM)
                                    .foregroundColor(theme.colors.textPrimary)
                                Text(
                                    purchase.datePurchased.formatted(
                                        date: .abbreviated, time: .shortened)
                                )
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                            }

                            Spacer()

                            Text("1 Item")  // Placeholder as Purchase doesn't have item count yet
                                .font(theme.typography.bodyS)
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 80, alignment: .trailing)

                            Text(purchase.cost.formatted(.currency(code: "USD")))
                                .font(theme.typography.bodyM)
                                .fontWeight(.medium)
                                .foregroundColor(theme.colors.textPrimary)
                                .frame(width: 100, alignment: .trailing)
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
