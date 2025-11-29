import SwiftUI

struct AppHeader: View {
    let title: String
    let subtitle: String?
    let showBackButton: Bool
    let onBack: (() -> Void)?

    @Environment(\.theme) var theme

    init(
        title: String,
        subtitle: String? = nil,
        showBackButton: Bool = false,
        onBack: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.showBackButton = showBackButton
        self.onBack = onBack
    }

    var body: some View {
        HStack(spacing: theme.spacing.m) {
            if showBackButton {
                AppButton(icon: "arrow.left", style: .ghost) {
                    onBack?()
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(theme.typography.headingL)
                    .foregroundColor(theme.colors.textPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(theme.typography.bodyS)
                        .foregroundColor(theme.colors.textSecondary)
                }
            }

            Spacer()

            // Right side actions (User profile, etc.)
            HStack(spacing: theme.spacing.s) {
                AppButton(icon: "bell", style: .ghost) {
                    // Notification action
                }

                Circle()
                    .fill(theme.colors.surfaceSecondary)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("JD")
                            .font(theme.typography.caption)
                            .fontWeight(.bold)
                            .foregroundColor(theme.colors.textPrimary)
                    )
                    .overlay(
                        Circle()
                            .stroke(theme.colors.borderSubtle, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, theme.spacing.xl)
        .padding(.vertical, theme.spacing.l)
        .background(
            theme.colors.backgroundPrimary.opacity(0.8)
                .blur(radius: 20)
        )
        // Make the header draggable on macOS
        #if os(macOS)
            .onHover { _ in
                // This is a workaround to make the area draggable if needed,
                // but usually we rely on the window background dragging or specific drag areas.
                // For now, we'll assume the user can drag from empty spaces.
            }
        #endif
    }
}
