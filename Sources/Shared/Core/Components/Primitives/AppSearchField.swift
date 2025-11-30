import SwiftUI

struct AppSearchField: View {
    @Binding var text: String
    var placeholder: String = "Search..."

    @Environment(\.theme) var theme

    var body: some View {
        HStack(spacing: theme.spacing.s) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(theme.colors.textMuted)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .font(theme.typography.bodyM)
                .foregroundColor(theme.colors.textPrimary)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(theme.colors.textMuted)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, theme.spacing.s)
        .padding(.horizontal, theme.spacing.m)
        .background(theme.colors.surfaceSecondary)
        .cornerRadius(theme.radii.pill)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.pill)
                .stroke(theme.colors.borderSubtle, lineWidth: 1)
        )
    }
}
