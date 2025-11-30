import SwiftUI

struct QuickListRow: View {
    @Environment(\.theme) var theme
    let item: QuickListItem
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: theme.spacing.m) {
                // Icon
                ZStack {
                    Circle()
                        .fill(theme.colors.surfaceSecondary)
                        .frame(width: 36, height: 36)

                    Image(systemName: item.icon)
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.accentPrimary)
                }

                // Text
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
                    .foregroundColor(theme.colors.textPrimary)
            }
            .padding(theme.spacing.s)
            .background(theme.colors.surfacePrimary)
            .cornerRadius(theme.radii.small)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
