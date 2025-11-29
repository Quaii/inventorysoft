import SwiftUI

struct InventoryView: View {
    @StateObject var viewModel: InventoryViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.m) {
                // Header & Controls
                HStack(spacing: theme.spacing.m) {
                    Text("Inventory")
                        .font(theme.typography.h2)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    AppButton(title: "Add Item", icon: "plus", style: .primary) {
                        // Action to open add item sheet (to be implemented)
                    }
                }

                HStack(spacing: theme.spacing.m) {
                    AppSearchField(text: $viewModel.searchText, placeholder: "Search items...")
                        .frame(maxWidth: 300)

                    // Filter by Status (Simplified for now)
                    // AppDropdown(title: "Status", selection: $viewModel.selectedStatus) { ... }

                    Spacer()
                }

                // Content
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(theme.colors.error)
                } else {
                    AppTable(viewModel.items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(theme.typography.bodyM)
                                    .foregroundColor(theme.colors.textPrimary)
                                Text(item.sku ?? "No SKU")
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.textSecondary)
                            }

                            Spacer()

                            Text("\(item.quantity)")
                                .font(theme.typography.bodyM)
                                .foregroundColor(theme.colors.textPrimary)
                                .frame(width: 50, alignment: .trailing)

                            Text(item.purchasePrice.formatted(.currency(code: "USD")))
                                .font(theme.typography.bodyM)
                                .foregroundColor(theme.colors.textPrimary)
                                .frame(width: 80, alignment: .trailing)

                            AppStatusPill(status: item.status)
                                .frame(width: 100, alignment: .trailing)

                            // Context Menu or Actions
                            AppButton(icon: "trash", style: .ghost) {
                                Task {
                                    await viewModel.deleteItem(id: item.id)
                                }
                            }
                        }
                        .padding(.horizontal, theme.spacing.s)
                    }
                }
            }
        }
        .task {
            await viewModel.loadItems()
        }
        .onChange(of: viewModel.searchText) { _, _ in
            Task { await viewModel.loadItems() }
        }
    }
}
