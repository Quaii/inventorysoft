import SwiftUI

struct InventoryView: View {
    @StateObject var viewModel: InventoryViewModel
    @EnvironmentObject var appEnvironment: AppEnvironment

    @State private var columns: [TableColumnConfig] = []
    @State private var isLoadingColumns = true
    @State private var columnError: String?
    @State private var showingColumnConfig = false
    @State private var isGridView = true
    @State private var selectedItem: Item?
    @State private var isAddingItem = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Filters & Controls
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        // Search
                        TextField("Search items...", text: $viewModel.searchText)
                            .textFieldStyle(.roundedBorder)
                            .frame(maxWidth: 320)

                        // Category Filter
                        Picker(
                            "Category",
                            selection: Binding(
                                get: { viewModel.selectedCategory ?? "All" },
                                set: { viewModel.selectedCategory = $0 == "All" ? nil : $0 }
                            )
                        ) {
                            Text("All Categories").tag("All")
                            ForEach(viewModel.categories, id: \.self) { category in
                                Text(category).tag(category)
                            }
                        }
                        .frame(width: 160)

                        Spacer()

                        // View Toggle
                        Picker("View", selection: $isGridView) {
                            Image(systemName: "square.grid.2x2").tag(true)
                            Image(systemName: "list.bullet").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 100)

                        // Columns Button (List View Only)
                        if !isGridView {
                            Button(action: { showingColumnConfig = true }) {
                                Label("Columns", systemImage: "slider.horizontal.3")
                            }
                        }
                    }

                    // Status Filter (Secondary Row)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            Text("Status:")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Picker(
                                "Status",
                                selection: Binding(
                                    get: { viewModel.selectedStatus?.rawValue ?? "All" },
                                    set: { viewModel.selectedStatus = ItemStatus(rawValue: $0) }
                                )
                            ) {
                                Text("All Statuses").tag("All")
                                ForEach(ItemStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status.rawValue)
                                }
                            }
                            .frame(width: 160)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top)

                // Content
                contentView
            }
            .navigationTitle("Inventory")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { isAddingItem = true }) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingColumnConfig) {
            ColumnConfigurationView(
                tableType: .inventory,
                columnConfigService: viewModel.columnConfigService
            )
        }
        .sheet(item: $selectedItem) { item in
            ItemDetailView(itemId: item.id, viewModel: appEnvironment.makeItemDetailViewModel())
        }
        .sheet(isPresented: $isAddingItem) {
            ItemDetailView(viewModel: appEnvironment.makeItemDetailViewModel())
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
            ProgressView()
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
                        try? await viewModel.columnConfigService.resetToDefaults(for: .inventory)
                        await loadColumns()
                    }
                }
            }
        } else if viewModel.items.isEmpty {
            ContentUnavailableView {
                Label("No Items Yet", systemImage: "cube.box")
            } description: {
                Text("Start adding items to your inventory to track your products.")
            } actions: {
                Button("Add First Item") {
                    isAddingItem = true
                }
            }
        } else {
            if isGridView {
                gridView
            } else {
                tableView
            }
        }
    }

    // MARK: - Grid View
    private var gridView: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 280, maximum: 360), spacing: 16)
                ],
                spacing: 16
            ) {
                ForEach(viewModel.items) { item in
                    InventoryGridCard(item: item)
                        .onTapGesture {
                            selectedItem = item
                        }
                        .contextMenu {
                            itemContextMenu(for: item)
                        }
                }
            }
            .padding()
        }
    }

    // MARK: - Table View
    private var tableView: some View {
        VStack(spacing: 0) {
            // Header
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
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))

            List {
                ForEach(viewModel.items) { item in
                    InventoryRow(
                        item: item,
                        columns: columns.filter { $0.isVisible }.sorted {
                            $0.sortOrder < $1.sortOrder
                        }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedItem = item
                    }
                    .contextMenu {
                        itemContextMenu(for: item)
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    @ViewBuilder
    private func itemContextMenu(for item: Item) -> some View {
        Button {
            // Mark as sold action
        } label: {
            Label("Mark as Sold", systemImage: "tag.fill")
        }

        Button {
            selectedItem = item
        } label: {
            Label("Edit", systemImage: "pencil")
        }

        Divider()

        Button(role: .destructive) {
            Task {
                await viewModel.deleteItem(id: item.id)
            }
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }

    private func loadColumns() async {
        isLoadingColumns = true
        columnError = nil

        do {
            columns = try await viewModel.columnConfigService.getColumns(for: .inventory)
            isLoadingColumns = false
        } catch {
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
            columns = viewModel.columnConfigService.getDefaultColumns(for: .inventory)
        }
    }
}

// MARK: - Subviews

struct InventoryGridCard: View {
    let item: Item

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 0) {
                // Image Placeholder
                ZStack {
                    Color.gray.opacity(0.1)

                    Image(systemName: "photo")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipped()
                .cornerRadius(8)
                .padding(4)

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .top) {
                        Text(item.title)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer()

                        StatusBadge(status: item.status)
                    }

                    Text(item.brandId?.uuidString ?? "Unknown Brand")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer().frame(height: 4)

                    HStack {
                        Text(item.purchasePrice.formatted(.currency(code: "USD")))
                            .font(.body)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Spacer()

                        Text("Qty: \(item.quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
                .padding(8)
            }
        }
    }
}

struct InventoryRow: View {
    let item: Item
    let columns: [TableColumnConfig]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(columns) { column in
                if column.field == "status" {
                    StatusBadge(status: item.status)
                        .frame(width: column.width ?? 100, alignment: .leading)
                        .padding(.horizontal, 4)
                } else {
                    Text(formatItemField(item, field: column.field))
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(width: column.width ?? 100, alignment: .leading)
                        .padding(.horizontal, 4)
                }
            }
            Spacer()
        }
        .padding(.vertical, 4)
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

struct StatusBadge: View {
    let status: ItemStatus

    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }

    var color: Color {
        switch status {
        case .inStock: return .green
        case .listed: return .blue
        case .sold: return .purple
        case .reserved: return .orange
        case .archived: return .gray
        case .draft: return .secondary
        }
    }
}
