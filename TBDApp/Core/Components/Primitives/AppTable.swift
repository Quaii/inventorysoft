import SwiftUI

struct AppTable<Data: RandomAccessCollection, RowContent: View>: View
where Data.Element: Identifiable {
    let data: Data
    let rowContent: (Data.Element) -> RowContent

    @Environment(\.theme) var theme

    init(_ data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) {
        self.data = data
        self.rowContent = rowContent
    }

    var body: some View {
        List(data) { item in
            rowContent(item)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .padding(.vertical, theme.spacing.xs)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(theme.colors.backgroundPrimary)
    }
}
