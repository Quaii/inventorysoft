import SwiftUI

struct AppTable<Data: RandomAccessCollection, RowContent: View, HeaderContent: View>: View
where Data.Element: Identifiable {
    let data: Data
    let rowContent: (Data.Element) -> RowContent
    let headerContent: () -> HeaderContent

    @Environment(\.theme) var theme
    @State private var hoveredItemId: Data.Element.ID?

    init(
        _ data: Data,
        @ViewBuilder header: @escaping () -> HeaderContent,
        @ViewBuilder row: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.headerContent = header
        self.rowContent = row
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                headerContent()
            }
            .font(theme.typography.tableHeader)
            .foregroundColor(theme.colors.tableHeader)
            .padding(.vertical, theme.spacing.xs)
            .padding(.horizontal, theme.spacing.m)
            .background(theme.colors.surfaceElevated)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(theme.colors.borderSubtle),
                alignment: .bottom
            )

            // Rows
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(data.enumerated()), id: \.element.id) { index, item in
                        rowContent(item)
                            .frame(height: 46)
                            .padding(.horizontal, theme.spacing.m)
                            .background(
                                rowBackground(for: item, at: index)
                            )
                            .contentShape(Rectangle())
                            .onHover { isHovering in
                                hoveredItemId = isHovering ? item.id : nil
                            }
                            .overlay(
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(theme.colors.divider),
                                alignment: .bottom
                            )
                    }
                }
            }
            .inventorySoftScrollStyle()
        }
        .background(theme.colors.surfacePrimary)
        .cornerRadius(theme.radii.medium)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.medium)
                .stroke(theme.colors.borderSubtle, lineWidth: 1)
        )
        // Ensure top alignment in parent container
        .frame(maxHeight: .infinity, alignment: .top)
    }

    private func rowBackground(for item: Data.Element, at index: Int) -> Color {
        if hoveredItemId == item.id {
            return theme.colors.surfaceElevated.opacity(0.5)
        }
        return index % 2 == 0 ? Color.clear : theme.colors.backgroundSecondary.opacity(0.3)
    }
}

// Convenience init for simple text headers if needed, but keeping generic is better for flexibility
extension AppTable where HeaderContent == EmptyView {
    init(_ data: Data, @ViewBuilder row: @escaping (Data.Element) -> RowContent) {
        self.data = data
        self.headerContent = { EmptyView() }
        self.rowContent = row
    }
}
