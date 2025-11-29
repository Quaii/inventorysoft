import SwiftUI

struct DashboardView: View {
    @StateObject var viewModel: DashboardViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            ScrollView {
                VStack(spacing: theme.spacing.l) {
                    Text("Dashboard")
                        .font(theme.typography.headingL)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: theme.spacing.m) {
                        AppCard {
                            VStack(alignment: .leading, spacing: theme.spacing.s) {
                                Text("Total Items")
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.textSecondary)
                                Text("\(viewModel.totalItems)")
                                    .font(theme.typography.headingM)
                                    .foregroundColor(theme.colors.textPrimary)
                            }
                        }

                        AppCard {
                            VStack(alignment: .leading, spacing: theme.spacing.s) {
                                Text("Total Sales")
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.textSecondary)
                                Text(
                                    "$\(NSDecimalNumber(decimal: viewModel.totalSales).stringValue)"
                                )
                                .font(theme.typography.headingM)
                                .foregroundColor(theme.colors.textPrimary)
                            }
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
    }
}
