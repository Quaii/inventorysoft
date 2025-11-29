import SwiftUI

struct SalesListView: View {
    @StateObject var viewModel: SalesViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.xl) {
                // Header
                HStack {
                    Text("Sales")
                        .font(theme.typography.headingXL)
                        .foregroundColor(theme.colors.textPrimary)
                    Spacer()
                    AppButton(title: "New Sale", icon: "plus", style: .primary) {
                        // Navigate to new sale
                    }
                }

                // Content
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    AppTable(viewModel.sales) { sale in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(sale.platform)
                                    .font(theme.typography.bodyM)
                                    .foregroundColor(theme.colors.textPrimary)
                                Text(sale.dateSold.formatted(date: .abbreviated, time: .shortened))
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.textSecondary)
                            }

                            Spacer()

                            Text("1 Item")  // Placeholder as Sale doesn't have item count yet
                                .font(theme.typography.bodyS)
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 80, alignment: .trailing)

                            Text(sale.soldPrice.formatted(.currency(code: "USD")))
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
            await viewModel.loadSales()
        }
    }
}
