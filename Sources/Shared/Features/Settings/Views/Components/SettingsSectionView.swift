import SwiftUI

/// Reusable section container for Settings page
struct SettingsSectionView<Content: View>: View {
    let title: String
    let description: String?
    let content: Content

    @Environment(\.theme) var theme

    init(
        title: String,
        description: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.m) {
            // Section Header
            VStack(alignment: .leading, spacing: theme.spacing.xs) {
                Text(title)
                    .font(theme.typography.cardTitle)
                    .foregroundColor(theme.colors.textPrimary)

                if let description = description {
                    Text(description)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }

            // Section Content
            VStack(spacing: theme.spacing.m) {
                content
            }
        }
        .padding(theme.spacing.l)
        .background(theme.colors.surfaceElevated)
        .cornerRadius(theme.radii.card)
    }
}
