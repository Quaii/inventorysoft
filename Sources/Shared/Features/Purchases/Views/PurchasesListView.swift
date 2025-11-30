import SwiftUI

struct PurchasesListView: View {
    @StateObject var viewModel: PurchasesViewModel
    @Environment(\.theme) var theme
    @State private var columns: [TableColumnConfig] = []
    @State private var isLoadingColumns = true
    @State private var columnError: String?
    @State private var showingColumnConfig = false

    var body: some View {
        ZStack {
            // Background
            theme.colors.backgroundPrimary
                .ignoresSafeArea()

            // Glow Blobs
            Circle()
                .fill(theme.colors.accentTertiary.opacity(0.1))
                .frame(width: 600, height: 600)
                .blur(radius: 120)
                .offset(x: 300, y: -200)

            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                // Page Header
                PageHeader(
                    breadcrumbPage: "Purchases",
                    title: "Purchase Orders",
                    subtitle: "Manage your supplier orders"
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
                        showingColumnConfig = true
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
            await viewModel.loadPurchases()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if isLoadingColumns || viewModel.isLoading {
            VStack(spacing: theme.spacing.m) {
                ProgressView()
                Text(isLoadingColumns ? "Loading columns..." : "Loading purchases...")
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
                                for: .purchases)
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
                title: "Error Loading Purchases",
                message: error,
                icon: "exclamationmark.triangle",
                actionTitle: "Retry",
                action: {
                    Task {
                        await viewModel.loadPurchases()
                    }
                }
            )
        } else if viewModel.purchases.isEmpty {
            VStack(spacing: theme.spacing.l) {
                Image(systemName: "cart")
                    .font(.system(size: 64))
                    .foregroundColor(theme.colors.textSecondary)

                VStack(spacing: theme.spacing.s) {
                    Text("No Purchases Yet")
                        .font(theme.typography.sectionTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Text("Start recording purchases to track your inventory costs.")
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                AppButton(title: "Record First Purchase", icon: "plus", style: .primary) {
                    // Navigate to record purchase
                }
                .frame(maxWidth: 200)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            DynamicTable(
                columns: columns.filter { $0.isVisible },
                rows: viewModel.purchases,
                rowContent: { purchase, column in
                    formatPurchaseField(purchase, field: column.field)
                },
                onRowTap: { purchase in
                    // Navigate to purchase detail
                }
            )
        }
    }

    private func loadColumns() async {
        isLoadingColumns = true
        columnError = nil

        do {
            columns = try await viewModel.columnConfigService.getColumns(for: .purchases)
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
            columns = viewModel.columnConfigService.getDefaultColumns(for: .purchases)
        }
    }

    private func formatPurchaseField(_ purchase: Purchase, field: String) -> String {
        switch field {
        case "batchName": return purchase.batchName ?? "-"
        case "supplier": return purchase.supplier
        case "cost": return purchase.cost.formatted(.currency(code: "USD"))
        case "datePurchased":
            return purchase.datePurchased.formatted(date: .abbreviated, time: .omitted)
        default: return "-"
        }
    }

}
