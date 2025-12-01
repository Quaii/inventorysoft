import SwiftUI

struct InventoryView: View {
    @StateObject var viewModel: InventoryViewModel
    @Environment(\.theme) var theme
    @EnvironmentObject var appEnvironment: AppEnvironment
    @State private var columns: [TableColumnConfig] = []
    @State private var isLoadingColumns = true
    @State private var columnError: String?
    @State private var showingColumnConfig = false
    @State private var isGridView = true  // Default to Grid View
    @State private var selectedItem: Item?

    var body: some View {
        ZStack {
            // Background
            theme.colors.backgroundPrimary
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                // Page Header
                PageHeader(
                    breadcrumbPage: "Inventory",
                    title: "Inventory",
                    subtitle: "Manage your products and stock levels"
                ) {
                    AppButton(title: "Add Item", icon: "plus", style: .primary) {
                        // Create a new empty item or just open detail with nil id
                        // For now, we need a way to trigger "New Item"
                        // We can use a separate state or just pass nil to selectedItem if we change its type or use a separate bool
                        // Let's use a separate state for adding
                        isAddingItem = true
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

                    // View Toggle
                    HStack(spacing: 0) {
                        Button(action: { isGridView = true }) {
                            Image(systemName: "square.grid.2x2")
                                .foregroundColor(
                                    isGridView
                                        ? theme.colors.textPrimary : theme.colors.textSecondary
                                )
                                .padding(8)
                                .background(isGridView ? theme.colors.surfaceElevated : theme.colors.backgroundPrimary)
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)

                        Button(action: { isGridView = false }) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(
                                    !isGridView
                                        ? theme.colors.textPrimary : theme.colors.textSecondary
                                )
                                .padding(8)
                                .background(
                                    !isGridView ? theme.colors.surfaceElevated : theme.colors.backgroundPrimary
                                )
                                .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(4)
                    .background(theme.colors.surfaceSecondary)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.colors.borderSubtle, lineWidth: 1)
                    )

                    if !isGridView {
                        AppButton(icon: "slider.horizontal.3", style: .secondary) {
                            showingColumnConfig = true
                        }
                    }
                }

                // Content
                contentView
            }
            .padding(theme.spacing.xl)
            .frame(maxHeight: .infinity, alignment: .top)
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

    @State private var isAddingItem = false

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
                    isAddingItem = true
                }
                .frame(maxWidth: 200)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    GridItem(
                        .adaptive(minimum: 240, maximum: 300), spacing: theme.layout.cardSpacing)
                ],
                spacing: theme.layout.cardSpacing
            ) {
                ForEach(viewModel.items) { item in
                    InventoryGridCard(item: item)
                        .onTapGesture {
                            selectedItem = item
                        }
                        .contextMenu {
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
                }
            }
            .padding(.bottom, theme.spacing.xl)
        }
        .inventorySoftScrollStyle()
    }

    // MARK: - Table View
    private var tableView: some View {
        VStack(spacing: theme.spacing.m) {
            // Header
            HStack(spacing: 0) {
                ForEach(columns.filter { $0.isVisible }.sorted { $0.sortOrder < $1.sortOrder }) {
                    column in
                    Text(column.label)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                        .fontWeight(.semibold)
                        .frame(width: column.width ?? 100, alignment: .leading)
                        .padding(.horizontal, theme.spacing.s)
                }
                Spacer()
            }
            .padding(.horizontal, theme.spacing.m)

            // Rows
            ScrollView {
                LazyVStack(spacing: theme.spacing.s) {
                    ForEach(viewModel.items) { item in
                        InventoryRow(
                            item: item,
                            columns: columns.filter { $0.isVisible }.sorted {
                                $0.sortOrder < $1.sortOrder
                            }
                        )
                        .onTapGesture {
                            selectedItem = item
                        }
                        .contextMenu {
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
                    }
                }
            }
            .inventorySoftScrollStyle()
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
}

// MARK: - Subviews

struct InventoryGridCard: View {
    let item: Item
    @Environment(\.theme) var theme

    var body: some View {
        Card() {
            VStack(alignment: .leading, spacing: 0) {
                // Image
                ZStack {
                    theme.colors.surfaceSecondary
                    if let imageAttachment = item.images.first(where: { $0.isPrimary })
                        ?? item.images.first
                    {
                        // In a real app, load image from disk using relativePath
                        // For now, placeholder or system image if we can't load actual file easily in this snippet
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(theme.colors.textMuted)
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(theme.colors.textMuted)
                    }
                }
                .frame(height: 160)
                .frame(maxWidth: .infinity)
                .clipped()

                // Content
                VStack(alignment: .leading, spacing: theme.spacing.s) {
                    HStack {
                        Text(item.title)
                            .font(theme.typography.body)
                            .fontWeight(.medium)
                            .foregroundColor(theme.colors.textPrimary)
                            .lineLimit(1)

                        Spacer()

                        StatusBadge(status: item.status)
                    }

                    Text(item.brandId?.uuidString ?? "Unknown Brand")  // Placeholder for brand name lookup
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)

                    HStack {
                        Text(item.purchasePrice.formatted(.currency(code: "USD")))
                            .font(theme.typography.body)
                            .fontWeight(.bold)
                            .foregroundColor(theme.colors.textPrimary)

                        Spacer()

                        Text("Qty: \(item.quantity)")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                }
                .padding(theme.spacing.m)
            }
        }
    }
}

struct InventoryRow: View {
    let item: Item
    let columns: [TableColumnConfig]
    @Environment(\.theme) var theme

    var body: some View {
        Card {
            HStack(spacing: 0) {
                ForEach(columns) { column in
                    Text(formatItemField(item, field: column.field))
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textPrimary)
                        .frame(width: column.width ?? 100, alignment: .leading)
                        .padding(.horizontal, theme.spacing.s)
                        .padding(.vertical, theme.spacing.m)
                }
                Spacer()
            }
            .contentShape(Rectangle())
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

struct StatusBadge: View {
    let status: ItemStatus
    @Environment(\.theme) var theme

    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 10, weight: .bold))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.1))
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
    }

    var color: Color {
        switch status {
        case .inStock: return theme.colors.success
        case .listed: return theme.colors.accentPrimary
        case .sold: return theme.colors.accentSecondary
        case .reserved: return theme.colors.warning
        case .archived: return theme.colors.textMuted
        case .draft: return theme.colors.textSecondary
        }
    }
}
