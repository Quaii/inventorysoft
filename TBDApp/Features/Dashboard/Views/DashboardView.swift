import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.l) {
                // Header
                HStack {
                    Text("Dashboard")
                        .font(theme.typography.h1)
                        .foregroundColor(theme.colors.textPrimary)
                    Spacer()
                    AppButton(title: "Refresh", icon: "arrow.clockwise", style: .secondary) {
                        Task {
                            await viewModel.loadMetrics()
                        }
                    }
                }

                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(theme.colors.error)
                } else {
                    // Metrics Grid
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 200))], spacing: theme.spacing.m
                    ) {
                        MetricCard(
                            title: "Inventory Value",
                            value: viewModel.totalInventoryValue.formatted(.currency(code: "USD")))
                        MetricCard(
                            title: "Sales Revenue",
                            value: viewModel.totalSalesRevenue.formatted(.currency(code: "USD")))
                        MetricCard(
                            title: "Net Profit",
                            value: viewModel.totalNetProfit.formatted(.currency(code: "USD")))
                        MetricCard(title: "Total Items", value: "\(viewModel.itemCount)")
                        MetricCard(title: "Total Sales", value: "\(viewModel.saleCount)")
                    }
                }

                Spacer()
            }
        }
        .task {
            await viewModel.loadMetrics()
        }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.s) {
                Text(title)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
                Text(value)
                    .font(theme.typography.h2)
                    .foregroundColor(theme.colors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
