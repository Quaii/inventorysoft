import SwiftUI

struct InventoryView: View {
    @StateObject var viewModel: InventoryViewModel
    @Environment(\.theme) var theme
    @State private var columns: [TableColumnConfig] = []
    @State private var isLoadingColumns = true
    @State private var columnError: String?
    @State private var showingColumnConfig = false

    var body: some View {
        AppScreenContainer {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                // Page Header
                PageHeader(
                    breadcrumbPage: "Inventory",
                    title: "Inventory",
                    subtitle: "Manage your products and stock levels"
                ) {
                    AppButton(title: "Add Item", icon: "plus", style: .primary) {
                        // Navigate to add item
                    }
                }

                // Search/Filter Row
                HStack(spacing: theme.spacing.m) {
                    AppTextField(
                        placeholder: "Search items...", text: $viewModel.searchText,
                        icon: "magnifyingglass"
                    )
                    .frame(maxWidth: 320)

                    AppDropdown(
                        placeholder: "Category",
                        options: ["All"] + viewModel.categories,
                        selection: Binding(
                            get: { viewModel.selectedCategory ?? "All" },
                            set: { viewModel.selectedCategory = $0 == "All" ? nil : $0 }
                        )
                    )
                    .frame(width: 180)

                    AppDropdown(
                        placeholder: "Status",
                        options: ["All"] + ItemStatus.allCases.map { $0.rawValue },
                        selection: Binding(
                            get: { viewModel.selectedStatus?.rawValue ?? "All" },
                            set: { viewModel.selectedStatus = ItemStatus(rawValue: $0) }
                        )
                    )
                    .frame(width: 160)

                    Spacer()

                    AppButton(icon: "slider.horizontal.3", style: .secondary) {
                        showingColumnConfig = true
                    }
                }

                // Content
                contentView
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .sheet(isPresented: $showingColumnConfig) {
            ColumnConfigurationView(
                tableType: .inventory,
                columnConfigService: viewModel.columnConfigService
            )
        }
        .task {
            await loadColumns()
            await viewModel.loadItems()
        }
        .onChange(of: viewModel.searchText) { _, _ in
            Task { await viewModel.loadItems() }
        }
        .onChange(of: viewModel.selectedCategory) { _, _ in
            Task { await viewModel.loadItems() }
        }
        .onChange(of: viewModel.selectedStatus) { _, _ in
            Task { await viewModel.loadItems() }
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if isLoadingColumns || viewModel.isLoading {
            VStack(spacing: theme.spacing.m) {
                ProgressView()
                    .scaleEffect(1.2)
                Text(isLoadingColumns ? "Loading columns..." : "Loading items...")
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
                            try await viewModel.columnConfigService.resetToDefaults(for: .inventory)
                            await loadColumns()
                        } catch {
                            print("Reset columns error: \(error)")
                        }
                    }
                }
                .frame(maxWidth: 300)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if columns.filter({ $0.isVisible }).isEmpty {
            AppEmptyStateView(
                title: "No Columns Configured",
                message: "Configure which columns to display in your inventory table.",
                icon: "tablecells",
                actionTitle: "Configure Columns",
                action: {
                    showingColumnConfig = true
                }
            )
        } else if let error = viewModel.errorMessage {
            AppEmptyStateView(
                title: "Error Loading Items",
                message: error,
                icon: "exclamationmark.triangle",
                actionTitle: "Retry",
                action: {
                    Task {
                        await viewModel.loadItems()
                    }
                }
            )
        } else if viewModel.items.isEmpty {
            VStack(spacing: theme.spacing.l) {
                Image(systemName: "cube.box")
                    .font(.system(size: 64))
                    .foregroundColor(theme.colors.textSecondary)

                VStack(spacing: theme.spacing.s) {
                    Text("No Items Yet")
                        .font(theme.typography.sectionTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Text("Start adding items to your inventory to track your products.")
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textSecondary)
                        .multilineTextAlignment(.center)
                }

                AppButton(title: "Add First Item", icon: "plus", style: .primary) {
                    // Navigate to add item
                }
                .frame(maxWidth: 200)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            DynamicTable(
                columns: columns.filter { $0.isVisible },
                rows: viewModel.items,
                rowContent: { item, column in
                    formatItemField(item, field: column.field)
                },
                onRowTap: { item in
                    // Navigate to item detail
                }
            )
        }
    }

    private func loadColumns() async {
        isLoadingColumns = true
        columnError = nil

        do {
            columns = try await viewModel.columnConfigService.getColumns(for: .inventory)
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
            columns = viewModel.columnConfigService.getDefaultColumns(for: .inventory)
        }
    }

    private func formatItemField(_ item: Item, field: String) -> String {
        switch field {
        case "title": return item.title
        case "sku": return item.sku ?? "-"
        case "category": return item.category ?? "-"
        case "purchasePrice": return item.purchasePrice.formatted(.currency(code: "USD"))
        case "quantity": return "\(item.quantity)"
        case "status": return item.status.rawValue
        case "dateAdded": return item.dateAdded.formatted(date: .abbreviated, time: .omitted)
        default: return "-"
        }
    }
}
