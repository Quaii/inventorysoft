import SwiftUI

struct InventoryView: View {
    @StateObject var viewModel: InventoryViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.m) {
                HStack {
                    Text("Inventory")
                        .font(theme.typography.headingL)
                    Spacer()
                    AppButton(title: "Add Item", icon: "plus") {
                        // Action to add item
                    }
                }

                List(viewModel.items) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(theme.typography.bodyM)
                                .fontWeight(.medium)
                            Text(item.status.rawValue)
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                        }
                        Spacer()
                        Text("$\(NSDecimalNumber(decimal: item.purchasePrice).stringValue)")
                            .font(theme.typography.bodyM)
                    }
                }
                .listStyle(.plain)
            }
        }
        .task {
            await viewModel.loadItems()
        }
    }
}
