import SwiftUI

struct AppTextField: View {
    let title: String?
    let placeholder: String
    @Binding var text: String

    @Environment(\.theme) var theme

    init(_ title: String? = nil, placeholder: String = "", text: Binding<String>) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            if let title = title {
                Text(title)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            TextField(placeholder, text: $text)
                .padding(theme.spacing.s)
                .background(theme.colors.backgroundSecondary)
                .cornerRadius(theme.radii.medium)
                .font(theme.typography.bodyM)
                .textFieldStyle(.plain)
        }
    }
}
