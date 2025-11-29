import SwiftUI

struct AppStatusPill: View {
    let text: String
    let color: Color

    @Environment(\.theme) var theme

    var body: some View {
        Text(text)
            .font(theme.typography.caption)
            .fontWeight(.medium)
            .padding(.horizontal, theme.spacing.s)
            .padding(.vertical, theme.spacing.xxs)
            .background(color.opacity(0.2))
            .foregroundColor(color)
            .cornerRadius(theme.radii.pill)
    }
}
