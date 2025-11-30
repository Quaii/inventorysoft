import SwiftUI

struct AppTextField: View {
    let title: String?
    let placeholder: String
    @Binding var text: String
    let icon: String?
    let isSecure: Bool

    @Environment(\.theme) var theme
    @FocusState private var isFocused: Bool

    init(
        _ title: String? = nil, placeholder: String = "", text: Binding<String>,
        icon: String? = nil, isSecure: Bool = false
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.icon = icon
        self.isSecure = isSecure
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
            }

            HStack(spacing: theme.spacing.s) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(theme.colors.textSecondary)
                }

                if isSecure {
                    SecureField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                } else {
                    TextField(placeholder, text: $text)
                        .textFieldStyle(.plain)
                }
            }
            .padding(.vertical, theme.spacing.s)
            .padding(.horizontal, theme.spacing.m)
            .background(theme.colors.surfaceSecondary)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(theme.colors.borderSubtle, lineWidth: 1)
            )
            .foregroundColor(theme.colors.textPrimary)
        }
    }
}
