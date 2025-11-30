import SwiftUI

/// Canonical settings section card with consistent padding and spacing
struct SettingsSectionCard<Content: View>: View {
    let title: String
    let description: String?
    let content: Content
    let isDangerZone: Bool

    @Environment(\.theme) var theme

    init(
        title: String,
        description: String? = nil,
        isDangerZone: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.description = description
        self.isDangerZone = isDangerZone
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.m) {
            // Section Header
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(theme.typography.sectionTitle)
                    .foregroundColor(isDangerZone ? theme.colors.error : theme.colors.textPrimary)

                if let description = description {
                    Text(description)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(.horizontal, 28)
            .padding(.top, 24)

            // Section Content
            VStack(spacing: 0) {
                content
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 24)
        }
        .background(theme.colors.surfaceElevated)
        .cornerRadius(theme.radii.card)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.card)
                .stroke(isDangerZone ? theme.colors.error.opacity(0.5) : .clear, lineWidth: 1)
        )
    }
}
