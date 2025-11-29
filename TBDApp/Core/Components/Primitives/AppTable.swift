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
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Item")
                Spacer()
                Text("Details")
            }
            .font(theme.typography.caption)
            .foregroundColor(theme.colors.textSecondary)
            .padding(theme.spacing.m)
            .background(theme.colors.surfaceSecondary)

            // Rows
            LazyVStack(spacing: 0) {
                ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                    rowContent(item)
                        .padding(.vertical, theme.spacing.m)
                        .padding(.horizontal, theme.spacing.m)
                        .background(
                            index % 2 == 0
                                ? Color.clear : theme.colors.backgroundSecondary.opacity(0.3)
                        )
                        .contentShape(Rectangle())
                        // Hover effect could be added here with onHover
                        .overlay(
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(theme.colors.borderSubtle.opacity(0.5)),
                            alignment: .bottom
                        )
                }
            }
        }
        .background(theme.colors.surfacePrimary)
        .cornerRadius(theme.radii.medium)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.medium)
                .stroke(theme.colors.borderSubtle, lineWidth: 1)
        )
    }
}
