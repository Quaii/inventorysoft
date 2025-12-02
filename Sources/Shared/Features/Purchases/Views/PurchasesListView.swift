import SwiftUI

struct PurchasesListView: View {
    @StateObject var viewModel: PurchasesViewModel
    @State private var columns: [TableColumnConfig] = []
    @State private var isLoadingColumns = true
    @State private var columnError: String?
    @State private var showingColumnConfig = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                HStack {
                    TextField("Search orders...", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 300)

                    Spacer()

                    Button(action: { showingColumnConfig = true }) {
                        Label("Columns", systemImage: "slider.horizontal.3")
                    }
                }
                .padding()

                // Content
                contentView
            }
            .navigationTitle("Purchase Orders")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        // Navigate to add order
                    }) {
                        Label("New Order", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingColumnConfig) {
            ColumnConfigurationView(
                tableType: .purchases,
                columnConfigService: viewModel.columnConfigService
            )
        }
        .task {
            await loadColumns()
            await viewModel.loadPurchases()
        }
    }

    @ViewBuilder
    private var contentView: some View {
        if isLoadingColumns || viewModel.isLoading {
            ProgressView("Loading...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let error = columnError {
            ContentUnavailableView {
                Label("Column Configuration Error", systemImage: "tablecells.badge.ellipsis")
            } description: {
                Text(error)
            } actions: {
                Button("Retry") {
                    Task { await loadColumns() }
                }
                Button("Reset Columns", role: .destructive) {
                    Task {
                        try? await viewModel.columnConfigService.resetToDefaults(for: .purchases)
                        await loadColumns()
                    }
                }
            }
        } else if let error = viewModel.errorMessage {
            ContentUnavailableView {
                Label("Error Loading Purchases", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error)
            } actions: {
                Button("Retry") {
                    Task { await viewModel.loadPurchases() }
                }
            }
        } else if viewModel.purchases.isEmpty {
            ContentUnavailableView {
                Label("No Purchases Yet", systemImage: "cart")
            } description: {
                Text("Start recording purchases to track your inventory costs.")
            } actions: {
                Button("Record First Purchase") {
                    // Navigate to record purchase
                }
            }
        } else {
            List {
                Section(header: tableHeader) {
                    ForEach(viewModel.purchases) { purchase in
                        HStack(spacing: 0) {
                            ForEach(
                                columns.filter { $0.isVisible }.sorted {
                                    $0.sortOrder < $1.sortOrder
                                }
                            ) { column in
                                Text(formatPurchaseField(purchase, field: column.field))
                                    .font(.body)
                                    .frame(width: column.width ?? 100, alignment: .leading)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 8)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Navigate to purchase detail
                        }
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            ForEach(columns.filter { $0.isVisible }.sorted { $0.sortOrder < $1.sortOrder }) {
                column in
                Text(column.label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                    .frame(width: column.width ?? 100, alignment: .leading)
                    .padding(.horizontal, 4)
            }
            Spacer()
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
