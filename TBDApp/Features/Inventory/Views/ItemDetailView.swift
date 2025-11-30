import SwiftUI

struct ItemDetailView: View {
    let itemId: UUID?
    @StateObject var viewModel: ItemDetailViewModel
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss

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

                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        HStack(alignment: .top, spacing: theme.spacing.xl) {
                            // Left Column: Image and Basic Info
                            VStack(spacing: theme.spacing.l) {
                                // Image Placeholder
                                AppCard {
                                    ZStack {
                                        theme.colors.surfaceSecondary
                                        if let image = viewModel.selectedImage {
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
                                            VStack(spacing: theme.spacing.s) {
                                                Image(systemName: "photo")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(theme.colors.textMuted)
                                                Text("Upload Image")
                                                    .font(theme.typography.bodyM)
                                                    .foregroundColor(theme.colors.textSecondary)
                                            }
                                        }
                                    }
                                    .frame(height: 300)
                                    .cornerRadius(theme.radii.medium)
                                    .onTapGesture {
                                        // Trigger image picker
                                    }
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
                }
            }
        }
    }
}
