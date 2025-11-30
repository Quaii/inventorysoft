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
        VStack(alignment: .leading, spacing: theme.spacing.s) {
            // Header with View All button
            HStack {
                Spacer()

                Button(action: onViewAll) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(theme.typography.caption)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                    }
                    .foregroundColor(theme.colors.accentSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, theme.spacing.m)
            .padding(.top, theme.spacing.xs)

            Divider()
                .padding(.horizontal, theme.spacing.m)

            // Items List
            if items.isEmpty {
                QuickListEmptyState(listType: listType)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: theme.spacing.s) {
                        ForEach(items) { item in
                            QuickListRow(
                                item: item,
                                onTap: {
                                    onItemTap(item)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, theme.spacing.m)
                    .padding(.bottom, theme.spacing.s)
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
        VStack(spacing: theme.spacing.m) {
            Image(systemName: listType.icon)
                .font(.system(size: 32))
                .foregroundColor(theme.colors.textSecondary.opacity(0.3))

            Text("No recent \(listType.defaultTitle.lowercased())")
                .font(theme.typography.body)
                .foregroundColor(theme.colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, theme.spacing.xl)
    }
}
