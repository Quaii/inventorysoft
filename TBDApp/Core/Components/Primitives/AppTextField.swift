import SwiftUI

struct AppTextField: View {
    let title: String
    @Binding var text: String

    @Environment(\.theme) var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)

            TextField("", text: $text)
                .padding(theme.spacing.s)
                .background(theme.colors.backgroundSecondary)
                .cornerRadius(theme.radii.medium)
                .font(theme.typography.bodyM)
        }
    }
}
