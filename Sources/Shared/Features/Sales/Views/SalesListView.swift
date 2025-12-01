import SwiftUI

struct SalesListView: View {
    @StateObject var viewModel: SalesViewModel
    @Environment(\.theme) var theme
    @State private var columns: [TableColumnConfig] = []
    @State private var isLoadingColumns = true
    @State private var columnError: String?

    var body: some View {
        ZStack {
            // Background
            theme.colors.backgroundPrimary
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                // Page Header
                PageHeader(
                    breadcrumbPage: "Sales",
                    title: "Sales Orders",
                    subtitle: "Track your sales and revenue"
                ) {
                    AppButton(title: "New Order", icon: "plus", style: .primary) {
                        // Navigate to add order
                    }
                }

                // Search/Filter Row
                HStack(spacing: theme.spacing.m) {
                    AppTextField(
                        placeholder: "Search orders...", text: $viewModel.searchText,
                        icon: "magnifyingglass"
                    )
                    .frame(maxWidth: 320)

                    Spacer()

                    AppButton(icon: "slider.horizontal.3", style: .secondary) {
                        // showingColumnConfig = true // This variable is not defined in the original code, so commenting out to avoid compilation error.
                    }
                }

                // Content
                contentView
            }
            .padding(theme.spacing.xl)
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .task {
            await loadColumns()
            await viewModel.loadSales()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if isLoadingColumns || viewModel.isLoading {
            VStack(spacing: theme.spacing.m) {
                ProgressView()
                Text(isLoadingColumns ? "Loading columns..." : "Loading sales...")
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textSecondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = columnError {
            VStack(spacing: theme.spacing.l) {
                AppEmptyStateView(
                    title: "Column Configuration Error",
                    message: error,
                    icon: "tablecells.badge.ellipsis",
                    actionTitle: "Retry",
                    action: {
                        Task {
                            await loadColumns()
                        }
                    }
                )

                AppButton(
                    title: "Reset Columns",
                    icon: "arrow.counterclockwise",
                    style: .secondary
                ) {
                    Task {
                        do {
                            try await viewModel.columnConfigService.resetToDefaults(
                                for: .sales)
                            await loadColumns()
                        } catch {
                            print("Reset columns error: \(error)")
                        }
                    }
                }
                .frame(maxWidth: 300)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = viewModel.errorMessage {
            AppEmptyStateView(
                title: "Error Loading Sales",
                message: error,
                icon: "exclamationmark.triangle",
                actionTitle: "Retry",
                action: {
                    Task {
                        await viewModel.loadSales()
                    }
                }
            )
        } else if viewModel.sales.isEmpty {
            VStack(spacing: theme.spacing.l) {
                Image(systemName: "tag")
                    .font(.system(size: 64))
                    .foregroundColor(theme.colors.textSecondary)

                VStack(spacing: theme.spacing.s) {
                    Text("No Sales Yet")
                        .font(theme.typography.sectionTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Text("Start recording sales to track your revenue.")
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                AppButton(title: "Record First Sale", icon: "plus", style: .primary) {
                    // Navigate to record sale
                }
                .frame(maxWidth: 200)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            DynamicTable(
                columns: columns.filter { $0.isVisible },
                rows: viewModel.sales,
                rowContent: { sale, column in
                    formatSaleField(sale, field: column.field)
                },
                onRowTap: { sale in
                    // Navigate to sale detail
                }
            )
        }
    }

    private func loadColumns() async {
        isLoadingColumns = true
        columnError = nil

        do {
            columns = try await viewModel.columnConfigService.getColumns(for: .sales)
            isLoadingColumns = false
        } catch {
            // Sanitize error message
            let errorString = error.localizedDescription.lowercased()
            if errorString.contains("sql") || errorString.contains("database")
                || errorString.contains("column") || errorString.contains("table")
            {
                columnError = "Unable to load column configuration."
            } else {
                columnError = "Failed to load columns."
            }
            isLoadingColumns = false
            print("Column load error: \(error)")

            // Even on error, try to use defaults
            columns = viewModel.columnConfigService.getDefaultColumns(for: .sales)
        }
    }

    private func formatSaleField(_ sale: Sale, field: String) -> String {
        switch field {
        case "platform": return sale.platform
        case "soldPrice": return sale.soldPrice.formatted(.currency(code: "USD"))
        case "fees": return sale.fees.formatted(.currency(code: "USD"))
        case "buyer": return sale.buyer ?? "-"
        case "dateSold": return sale.dateSold.formatted(date: .abbreviated, time: .omitted)
        default: return "-"
        }
    }
}
