import SwiftUI

struct ItemDetailView: View {
    let itemId: UUID?
    @StateObject var viewModel: ItemDetailViewModel
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab = 0  // 0: Details, 1: Analytics

    init(itemId: UUID? = nil, viewModel: ItemDetailViewModel) {
        self.itemId = itemId
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.xl) {
                // Header
                HStack {
                    AppButton(icon: "arrow.left", style: .ghost) {
                        dismiss()
                    }
                    Text(viewModel.isNewItem ? "Add Item" : "Edit Item")
                        .font(theme.typography.headingXL)
                        .foregroundColor(theme.colors.textPrimary)
                    Spacer()
                    if !viewModel.isNewItem {
                        AppButton(title: "Delete", icon: "trash", style: .destructive) {
                            // Show delete confirmation
                        }
                    }
                    AppButton(title: "Save", icon: "checkmark", style: .primary) {
                        Task {
                            if await viewModel.saveItem() {
                                dismiss()
                            }
                        }
                    }
                }

                // Tab Picker
                if !viewModel.isNewItem {
                    Picker("View", selection: $selectedTab) {
                        Text("Details").tag(0)
                        Text("Analytics").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, theme.spacing.xl)
                }

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        if selectedTab == 0 {
                            detailsView
                        } else {
                            analyticsView
                        }
                    }
                }
            }
        }
        .task {
            if let id = itemId {
                await viewModel.loadItem(id: id)
            }
        }
    }

    // MARK: - Details View
    private var detailsView: some View {
        HStack(alignment: .top, spacing: theme.spacing.xl) {
            // Left Column: Image Gallery and Basic Info
            VStack(spacing: theme.spacing.l) {
                // Image Gallery
                AppCard {
                    ZStack {
                        theme.colors.surfaceSecondary
                        if !viewModel.images.isEmpty {
                            TabView {
                                ForEach(viewModel.images) { attachment in
                                    if let image = viewModel.loadedImages[attachment.id] {
                                        #if os(iOS)
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        #elseif os(macOS)
                                            Image(nsImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        #endif
                                    } else {
                                        ProgressView()
                                    }
                                }
                            }
                            #if os(iOS)
                                .tabViewStyle(.page)
                            #endif
                        } else {
                            VStack(spacing: theme.spacing.s) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 40))
                                    .foregroundColor(theme.colors.textMuted)
                                Text("No Images")
                                    .font(theme.typography.bodyM)
                                    .foregroundColor(theme.colors.textSecondary)
                            }
                        }
                    }
                    .frame(height: 300)
                    .cornerRadius(theme.radii.medium)
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                AppButton(icon: "plus", style: .secondary) {
                                    // Trigger image picker
                                }
                                .padding(theme.spacing.s)
                            }
                        }
                    )
                }

                AppCard {
                    VStack(alignment: .leading, spacing: theme.spacing.l) {
                        Text("Basic Information")
                            .font(theme.typography.headingM)
                            .foregroundColor(theme.colors.textPrimary)

                        AppTextField(
                            "Name", placeholder: "Item Name", text: $viewModel.name)
                        AppTextField(
                            "Brand", placeholder: "Brand", text: $viewModel.brand)

                        AppDropdown(
                            label: "Category",
                            placeholder: "Select Category",
                            options: viewModel.categories,
                            selection: $viewModel.selectedCategory
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity)

            // Right Column: Pricing and Inventory
            VStack(spacing: theme.spacing.l) {
                AppCard {
                    VStack(alignment: .leading, spacing: theme.spacing.l) {
                        Text("Pricing")
                            .font(theme.typography.headingM)
                            .foregroundColor(theme.colors.textPrimary)

                        HStack(spacing: theme.spacing.m) {
                            AppTextField(
                                "Purchase Price", placeholder: "0.00",
                                text: Binding(
                                    get: { String(viewModel.purchasePrice) },
                                    set: {
                                        viewModel.purchasePrice = Double($0) ?? 0
                                    }
                                ))

                            AppTextField(
                                "Selling Price", placeholder: "0.00",
                                text: Binding(
                                    get: { String(viewModel.sellingPrice) },
                                    set: {
                                        viewModel.sellingPrice = Double($0) ?? 0
                                    }
                                ))
                        }
                    }
                }

                AppCard {
                    VStack(alignment: .leading, spacing: theme.spacing.l) {
                        Text("Inventory")
                            .font(theme.typography.headingM)
                            .foregroundColor(theme.colors.textPrimary)

                        AppTextField(
                            "Quantity", placeholder: "0",
                            text: Binding(
                                get: { String(viewModel.quantity) },
                                set: { viewModel.quantity = Int($0) ?? 0 }
                            ))

                        AppDropdown(
                            label: "Status",
                            placeholder: "Select Status",
                            options: ItemStatus.allCases.map { $0.rawValue },
                            selection: Binding(
                                get: { viewModel.status.rawValue },
                                set: { newValue in
                                    if let newStatus = ItemStatus(
                                        rawValue: newValue)
                                    {
                                        viewModel.status = newStatus
                                    }
                                }
                            )
                        )
                    }
                }

                AppCard {
                    VStack(alignment: .leading, spacing: theme.spacing.l) {
                        Text("Notes")
                            .font(theme.typography.headingM)
                            .foregroundColor(theme.colors.textPrimary)

                        AppTextField(
                            "Description", placeholder: "Add notes...",
                            text: $viewModel.note
                        )
                        .frame(height: 100, alignment: .top)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Analytics View
    private var analyticsView: some View {
        VStack(spacing: theme.spacing.l) {
            if let sale = viewModel.sale {
                HStack(spacing: theme.spacing.l) {
                    // Profit Card
                    Card {
                        VStack(alignment: .leading, spacing: theme.spacing.m) {
                            HStack {
                                Image(systemName: "dollarsign.circle.fill")
                                    .foregroundColor(theme.colors.success)
                                Text("Net Profit")
                                    .font(theme.typography.body)
                                    .foregroundColor(theme.colors.textSecondary)
                            }

                            Text(viewModel.profit?.formatted(.currency(code: "USD")) ?? "-")
                                .font(theme.typography.headingXL)
                                .foregroundColor(theme.colors.textPrimary)
                        }
                        .padding(theme.spacing.l)
                    }

                    // Margin Card
                    Card {
                        VStack(alignment: .leading, spacing: theme.spacing.m) {
                            HStack {
                                Image(systemName: "percent")
                                    .foregroundColor(theme.colors.accentPrimary)
                                Text("Margin")
                                    .font(theme.typography.body)
                                    .foregroundColor(theme.colors.textSecondary)
                            }

                            Text(
                                viewModel.margin?.formatted(.number.precision(.fractionLength(1)))
                                    ?? "-" + "%"
                            )
                            .font(theme.typography.headingXL)
                            .foregroundColor(theme.colors.textPrimary)
                        }
                        .padding(theme.spacing.l)
                    }

                    // Days to Sell Card
                    Card {
                        VStack(alignment: .leading, spacing: theme.spacing.m) {
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(theme.colors.accentSecondary)
                                Text("Time to Sell")
                                    .font(theme.typography.body)
                                    .foregroundColor(theme.colors.textSecondary)
                            }

                            Text("\(viewModel.daysToSell ?? 0) Days")
                                .font(theme.typography.headingXL)
                                .foregroundColor(theme.colors.textPrimary)
                        }
                        .padding(theme.spacing.l)
                    }
                }

                // Sale Details
                Card {
                    VStack(alignment: .leading, spacing: theme.spacing.l) {
                        Text("Sale Details")
                            .font(theme.typography.headingM)
                            .foregroundColor(theme.colors.textPrimary)

                        Divider().background(theme.colors.borderSubtle)

                        HStack {
                            DetailRow(
                                label: "Sold Price",
                                value: sale.soldPrice.formatted(.currency(code: "USD")))
                            DetailRow(
                                label: "Fees", value: sale.fees.formatted(.currency(code: "USD")))
                            DetailRow(label: "Platform", value: sale.platform)
                            DetailRow(
                                label: "Date Sold",
                                value: sale.dateSold.formatted(date: .abbreviated, time: .omitted))
                        }
                    }
                    .padding(theme.spacing.l)
                }
            } else {
                VStack(spacing: theme.spacing.l) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 64))
                        .foregroundColor(theme.colors.textMuted)

                    Text("No Sales Data")
                        .font(theme.typography.headingM)
                        .foregroundColor(theme.colors.textPrimary)

                    Text("This item has not been sold yet.")
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textSecondary)
                }
                .frame(height: 300)
                .frame(maxWidth: .infinity)
                .background(theme.colors.surfaceSecondary.opacity(0.3))
                .cornerRadius(theme.radii.medium)
            }
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    @Environment(\.theme) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)
            Text(value)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
