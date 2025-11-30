import SwiftUI

struct RecentItemsCard: View {
    let items: [RecentItemInfo]
    let onViewAll: () -> Void
    let onViewItem: (RecentItemInfo) -> Void

    @Environment(\.theme) var theme
    @State private var selectedTab = 0

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                // Header
                HStack {
                    Text("Recent Items")
                        .font(theme.typography.cardTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    // Segmented Control
                    HStack(spacing: 0) {
                        Button(action: { selectedTab = 0 }) {
                            Text("Latest Items")
                                .font(theme.typography.caption)
                                .foregroundColor(
                                    selectedTab == 0
                                        ? theme.colors.textPrimary : theme.colors.textSecondary
                                )
                                .padding(.horizontal, theme.spacing.m)
                                .padding(.vertical, theme.spacing.s)
                                .background(
                                    selectedTab == 0 ? theme.colors.surfaceElevated : Color.clear
                                )
                                .cornerRadius(theme.radii.small)
                        }
                        .buttonStyle(.plain)

                        Button(action: onViewAll) {
                            Text("View All")
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                                .padding(.horizontal, theme.spacing.m)
                                .padding(.vertical, theme.spacing.s)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Content
                if items.isEmpty {
                    // Empty State
                    VStack(spacing: theme.spacing.m) {
                        Spacer()

                        Image(systemName: "cube.box")
                            .font(.system(size: 48))
                            .foregroundColor(theme.colors.textSecondary)

                        Text("No items yet")
                            .font(theme.typography.sectionTitle)
                            .foregroundColor(theme.colors.textPrimary)

                        Text("Start adding items to your inventory to see them here.")
                            .font(theme.typography.body)
                            .foregroundColor(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                } else {
                    // Table
                    VStack(spacing: 0) {
                        // Header Row
                        HStack(spacing: theme.spacing.m) {
                            Text("ITEM")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 150, alignment: .leading)

                            Text("BRAND")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 100, alignment: .leading)

                            Text("SIZE")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 60, alignment: .leading)

                            Text("CONDITION")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 100, alignment: .leading)

                            Text("PRICE")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 80, alignment: .leading)

                            Text("QUERY")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(minWidth: 100, alignment: .leading)

                            Text("TIMESTAMP")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 120, alignment: .leading)

                            Text("ACTION")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 80, alignment: .trailing)
                        }
                        .padding(.vertical, theme.spacing.s)

                        Divider().overlay(theme.colors.divider)

                        // Data Rows
                        ForEach(items) { item in
                            HStack(spacing: theme.spacing.m) {
                                // Item with image
                                HStack(spacing: theme.spacing.s) {
                                    if let imageURL = item.imageURL {
                                        AsyncImage(url: URL(string: imageURL)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Rectangle()
                                                .fill(theme.colors.surfaceSecondary)
                                        }
                                        .frame(width: 32, height: 32)
                                        .cornerRadius(4)
                                    }

                                    Text(item.title)
                                        .font(theme.typography.body)
                                        .foregroundColor(theme.colors.textPrimary)
                                        .lineLimit(1)
                                }
                                .frame(width: 150, alignment: .leading)

                                Text(item.brand)
                                    .font(theme.typography.body)
                                    .foregroundColor(theme.colors.textSecondary)
                                    .frame(width: 100, alignment: .leading)

                                Text(item.size)
                                    .font(theme.typography.body)
                                    .foregroundColor(theme.colors.textSecondary)
                                    .frame(width: 60, alignment: .leading)

                                Text(item.condition)
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.textPrimary)
                                    .padding(.horizontal, theme.spacing.s)
                                    .padding(.vertical, 2)
                                    .background(theme.colors.surfaceElevated)
                                    .cornerRadius(4)
                                    .frame(width: 100, alignment: .leading)

                                Text(item.price)
                                    .font(theme.typography.body)
                                    .foregroundColor(theme.colors.textPrimary)
                                    .frame(width: 80, alignment: .leading)

                                Text(item.query)
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.textSecondary)
                                    .lineLimit(1)
                                    .frame(minWidth: 100, alignment: .leading)

                                Text(item.timestamp)
                                    .font(theme.typography.caption)
                                    .foregroundColor(theme.colors.textSecondary)
                                    .frame(width: 120, alignment: .leading)

                                AppButton(
                                    title: "View",
                                    style: .secondary,
                                    action: { onViewItem(item) }
                                )
                                .frame(width: 80, alignment: .trailing)
                            }
                            .padding(.vertical, theme.spacing.s)

                            if item.id != items.last?.id {
                                Divider().overlay(theme.colors.divider)
                            }
                        }
                    }
                }
            }
        }
    }
}
