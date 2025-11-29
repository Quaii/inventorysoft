import SwiftUI

struct SalesListView: View {
    @StateObject var viewModel: SalesViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.m) {
                HStack {
                    Text("Sales")
                        .font(theme.typography.h2)
                        .foregroundColor(theme.colors.textPrimary)
                    Spacer()
                    AppButton(title: "Add Sale", icon: "plus", style: .primary) {
                        // Add sale action
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(theme.colors.error)
                } else {
                    AppTable(viewModel.sales) { sale in
                        HStack {
                            Text(sale.dateSold.formatted(date: .abbreviated, time: .omitted))
                                .font(theme.typography.bodyM)
                                .frame(width: 100, alignment: .leading)

                            Text(sale.platform)
                                .font(theme.typography.bodyM)
                                .frame(width: 100, alignment: .leading)

                            Spacer()

                            Text(sale.soldPrice.formatted(.currency(code: "USD")))
                                .font(theme.typography.bodyM)
                                .fontWeight(.semibold)
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
