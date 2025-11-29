import SwiftUI

struct AppDropdown<Selection: Hashable, Content: View>: View {
    let title: String
    @Binding var selection: Selection
    let content: Content

    @Environment(\.theme) var theme

    init(title: String, selection: Binding<Selection>, @ViewBuilder content: () -> Content) {
        self.title = title
        self._selection = selection
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(title)
                .font(theme.typography.caption)
                .foregroundColor(theme.colors.textSecondary)

            Picker(title, selection: $selection) {
                content
            }
            .pickerStyle(.menu)  // Use menu style for dropdown behavior
            .padding(theme.spacing.s)
            .background(theme.colors.surfaceElevated)
            .cornerRadius(theme.radii.medium)
        }
    }
}
