import SwiftUI

struct ItemDetailView: View {
    let itemId: UUID
    @StateObject var viewModel: ItemDetailViewModel
    @Environment(\.theme) var theme
    @Environment(\.dismiss) var dismiss

    // Local state for form fields (simplified for Phase 2)
    @State private var title: String = ""
    @State private var sku: String = ""
    @State private var price: String = ""
    @State private var quantity: String = ""
    @State private var status: ItemStatus = .draft

    var body: some View {
        AppScreenContainer {
            ScrollView {
                VStack(spacing: theme.spacing.l) {
                    // Header
                    HStack {
                        Text("Item Details")
                            .font(theme.typography.h2)
                            .foregroundColor(theme.colors.textPrimary)
                        Spacer()
                        AppButton(title: "Save", style: .primary) {
                            saveItem()
                        }
                    }

                    if viewModel.isLoading {
                        ProgressView()
                    } else if let error = viewModel.errorMessage {
                        Text(error).foregroundColor(theme.colors.error)
                    } else {
                        // Form
                        VStack(spacing: theme.spacing.m) {
                            AppTextField("Title", placeholder: "Item Title", text: $title)
                            AppTextField("SKU", placeholder: "SKU-123", text: $sku)

                            HStack(spacing: theme.spacing.m) {
                                AppTextField("Price", placeholder: "0.00", text: $price)
                                AppTextField("Quantity", placeholder: "1", text: $quantity)
                            }

                            AppDropdown(title: "Status", selection: $status) {
                                ForEach(ItemStatus.allCases, id: \.self) { status in
                                    Text(status.rawValue).tag(status)
                                }
                            }
                        }
                        .padding(theme.spacing.m)
                        .background(theme.colors.surfaceElevated)
                        .cornerRadius(theme.radii.large)

                        // Images Section (Placeholder)
                        VStack(alignment: .leading, spacing: theme.spacing.s) {
                            Text("Images")
                                .font(theme.typography.h3)

                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(viewModel.images) { image in
                                        // In real app, load image from disk. Here just a placeholder
                                        Rectangle()
                                            .fill(theme.colors.surfaceElevated)
                                            .frame(width: 100, height: 100)
                                            .overlay(Text(image.fileName).font(.caption))
                                            .cornerRadius(theme.radii.medium)
                                    }

                                    AppButton(icon: "plus", style: .secondary) {
                                        // Add image action
                                    }
                                }
                            }
                        }

                        // Delete Button
                        AppButton(title: "Delete Item", style: .destructive) {
                            // Delete action
                        }
                    }
                }
                .padding(theme.spacing.m)
            }
        }
        .task {
            await viewModel.loadItem(id: itemId)
            if let item = viewModel.item {
                self.title = item.title
                self.sku = item.sku ?? ""
                self.price = "\(item.purchasePrice)"
                self.quantity = "\(item.quantity)"
                self.status = item.status
            }
        }
    }

    private func saveItem() {
        guard let priceDecimal = Decimal(string: price), let quantityInt = Int(quantity) else {
            return
        }

        var item =
            viewModel.item
            ?? Item(
                title: title, purchasePrice: priceDecimal, quantity: quantityInt, status: status)
        item.title = title
        item.sku = sku
        item.purchasePrice = priceDecimal
        item.quantity = quantityInt
        item.status = status

        Task {
            await viewModel.saveItem(item)
            dismiss()
        }
    }
}
