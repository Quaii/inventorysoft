import SwiftUI

/// Quick list card showing recent activity (sales, purchases, or items)
struct QuickListCard: View {
    let title: String
    let items: [QuickListItem]
    let onViewAll: () -> Void
    let onItemTap: (QuickListItem) -> Void

    @Environment(\.theme) var theme

    var body: some View {
        Card {
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
