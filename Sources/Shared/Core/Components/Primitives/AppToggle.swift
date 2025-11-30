import SwiftUI

struct AppToggle: View {
    let title: String
    @Binding var isOn: Bool

    @Environment(\.theme) var theme

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(theme.typography.bodyM)
                .foregroundColor(theme.colors.textPrimary)
        }
        .toggleStyle(.switch)
        .padding(theme.spacing.s)
        .background(theme.colors.surfaceElevated)
        .cornerRadius(theme.radii.medium)
    }
}
