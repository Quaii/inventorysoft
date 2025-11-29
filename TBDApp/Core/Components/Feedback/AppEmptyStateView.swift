import SwiftUI

struct AppEmptyStateView: View {
    let title: String
    let message: String
    let icon: String
    let actionTitle: String?
    let action: (() -> Void)?

    @Environment(\.theme) var theme

    init(
        title: String,
        message: String,
        icon: String = "magnifyingglass",
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.icon = icon
        self.actionTitle = actionTitle
        self.action = action
    }

    var body: some View {
        VStack(spacing: theme.spacing.l) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(theme.colors.textMuted)

            VStack(spacing: theme.spacing.s) {
                Text(title)
                    .font(theme.typography.headingM)
                    .foregroundColor(theme.colors.textPrimary)

                Text(message)
                    .font(theme.typography.bodyM)
                    .foregroundColor(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }

            if let actionTitle = actionTitle, let action = action {
                AppButton(title: actionTitle, style: .primary, action: action)
            }
        }
        .padding(theme.spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
