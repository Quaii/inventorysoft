import SwiftUI

struct InventoryView: View {
    @StateObject var viewModel: InventoryViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.xl) {
                // Header
                HStack {
                    Text("Inventory")
                        .font(theme.typography.headingXL)
                        .foregroundColor(theme.colors.textPrimary)
                    Spacer()
                    AppButton(title: "Add Item", icon: "plus", style: .primary) {
                        // Navigate to add item
                    }
                }

                // Search and Filter Bar
                HStack(spacing: theme.spacing.m) {
                    AppSearchField(text: $viewModel.searchText, placeholder: "Search items...")
                        .frame(maxWidth: 400)

                    AppDropdown(
                        label: nil,
                        placeholder: "Category",
                        options: ["All"] + viewModel.categories,
                        selection: Binding(
                            get: { viewModel.selectedCategory ?? "All" },
                            set: { viewModel.selectedCategory = $0 == "All" ? nil : $0 }
                        )
                    )
                    .frame(width: 200)

                    Spacer()
                }

                // Content
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(theme.colors.error)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    AppTable(viewModel.items) { item in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.title)
                                    .font(theme.typography.bodyM)
                                    .foregroundColor(theme.colors.textPrimary)
                                Text(item.sku ?? "-")
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.textSecondary)
                            }

                            Spacer()
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
