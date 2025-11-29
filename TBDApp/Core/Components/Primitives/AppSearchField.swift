import SwiftUI

struct AppSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search..."

    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: theme.spacing.s) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(theme.colors.textSecondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(theme.typography.bodyM)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(theme.colors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(theme.spacing.s)
        .background(theme.colors.surfaceElevated)
        .cornerRadius(theme.radii.medium)
    }
}
