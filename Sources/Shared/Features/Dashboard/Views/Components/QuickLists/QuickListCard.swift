import SwiftUI

/// Quick list card showing recent activity (sales, purchases, or items)
struct QuickListCard: View {
    let title: String
    let items: [QuickListItem]
    let onViewAll: () -> Void
    let onItemTap: (QuickListItem) -> Void

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

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

                Divider()

                // Items List
                if items.isEmpty {
                    Text("No recent activity")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 16)
                } else {
                    VStack(spacing: 8) {
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
            .padding(4)
        }
    }
}
