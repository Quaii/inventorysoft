import SwiftUI

/// Quick list card showing recent activity (sales, purchases, or items)
struct QuickListCard: View {
    let title: String
    let items: [QuickListItem]
    let onViewAll: () -> Void
    let onItemTap: (QuickListItem) -> Void

    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                // Header
                HStack {
                    Text(title)
                        .font(theme.typography.sectionTitle)
                        .foregroundColor(theme.colors.textPrimary)

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

                Divider()

                // Items List
                if items.isEmpty {
                    Text("No recent activity")
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, theme.spacing.l)
                } else {
                    VStack(spacing: theme.spacing.s) {
                        ForEach(items) { item in
                            QuickListRow(
                                item: item,
                                onTap: {
                                    onItemTap(item)
                                })
                        }
                    }
                }
            }
            .padding(theme.spacing.l)
        }
    }
}

/// Individual row in quick list
struct QuickListRow: View {
    let item: QuickListItem
    let onTap: () -> Void

    @Environment(\.theme) var theme
    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: theme.spacing.m) {
                // Icon
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundColor(theme.colors.accentSecondary)
                    .frame(width: 24, height: 24)

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textPrimary)
                        .lineLimit(1)

                    Text(item.subtitle)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                        .lineLimit(1)
                }

                Spacer()

                // Value
                Text(item.value)
                    .font(theme.typography.body)
                    .fontWeight(.medium)
                    .foregroundColor(theme.colors.textPrimary)
            }
            .padding(.vertical, theme.spacing.xs)
            .padding(.horizontal, theme.spacing.s)
            .background(isHovered ? theme.colors.backgroundSecondary : Color.clear)
            .cornerRadius(theme.radii.small)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
