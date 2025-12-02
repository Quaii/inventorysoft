import SwiftUI

struct SalesListView: View {
    @StateObject var viewModel: SalesViewModel
    @State private var columns: [TableColumnConfig] = []
    @State private var isLoadingColumns = true
    @State private var columnError: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                HStack {
                    TextField("Search orders...", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 300)

                    Spacer()

                    // Column config button if needed, or put in toolbar
                }
                .padding()

                // Content
                contentView
            }
            .navigationTitle("Sales Orders")
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
        .task {
            await loadColumns()
            await viewModel.loadSales()
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
                        try? await viewModel.columnConfigService.resetToDefaults(for: .sales)
                        await loadColumns()
                    }
                }
            }
        } else if let error = viewModel.errorMessage {
            ContentUnavailableView {
                Label("Error Loading Sales", systemImage: "exclamationmark.triangle")
            } description: {
                Text(error)
            } actions: {
                Button("Retry") {
                    Task { await viewModel.loadSales() }
                }
            }
        } else if viewModel.sales.isEmpty {
            ContentUnavailableView {
                Label("No Sales Yet", systemImage: "tag")
            } description: {
                Text("Start recording sales to track your revenue.")
            } actions: {
                Button("Record First Sale") {
                    // Navigate to record sale
                }
            }
        } else {
            List {
                Section(header: tableHeader) {
                    ForEach(viewModel.sales) { sale in
                        HStack(spacing: 0) {
                            ForEach(
                                columns.filter { $0.isVisible }.sorted {
                                    $0.sortOrder < $1.sortOrder
                                }
                            ) { column in
                                Text(formatSaleField(sale, field: column.field))
                                    .font(.body)
                                    .frame(width: column.width ?? 100, alignment: .leading)
                                    .padding(.horizontal, 4)
                                    .padding(.vertical, 8)
                            }
                            Spacer()
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // Navigate to sale detail
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
