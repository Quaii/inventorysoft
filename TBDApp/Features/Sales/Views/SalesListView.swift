import SwiftUI

struct SalesListView: View {
    @StateObject var viewModel: SalesViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.m) {
                Text("Sales")
                    .font(theme.typography.headingL)
                    .frame(maxWidth: .infinity, alignment: .leading)

                List(viewModel.sales) { sale in
                    HStack {
                        Text(sale.date.formatted(date: .abbreviated, time: .shortened))
                        Spacer()
                        Text("$\(NSDecimalNumber(decimal: sale.amount).stringValue)")
                    }
                }
            }
        }
        .task {
            await viewModel.loadSales()
        }
    }
}
