import SwiftUI

/// Content view for quick list widgets (sales, purchases, items)
///
/// Displays a scrollable list of recent activity with icon, title, subtitle, and value.
/// Reuses the QuickListRow component for consistent styling.
struct QuickListWidgetContent: View {
    @Environment(\.theme) var theme
    let items: [QuickListItem]
    let listType: QuickListType
    let onItemTap: (QuickListItem) -> Void
    let onViewAll: () -> Void

    init(
        items: [QuickListItem],
        listType: QuickListType,
        onItemTap: @escaping (QuickListItem) -> Void = { _ in },
        onViewAll: @escaping () -> Void = {}
    ) {
        self.items = items
        self.listType = listType
        self.onItemTap = onItemTap
        self.onViewAll = onViewAll
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with View All button
            HStack {
                Spacer()

                Button(action: onViewAll) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.caption)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)

            Divider()
                .padding(.horizontal, 16)

            // Items List
            if items.isEmpty {
                QuickListEmptyState(listType: listType)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        ForEach(items) { item in
                            QuickListRow(
                                item: item,
                                onTap: {
                                    onItemTap(item)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Empty state for quick list widgets
struct QuickListEmptyState: View {
    @Environment(\.theme) var theme
    let listType: QuickListType

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: listType.icon)
                .font(.system(size: 32))
                .foregroundColor(.secondary.opacity(0.3))

            Text("No recent \(listType.defaultTitle.lowercased())")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
