import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.m) {
                Text("Settings")
                    .font(theme.typography.headingL)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Toggle("Dark Mode", isOn: $viewModel.isDarkMode)
                    .padding()
                    .background(theme.colors.surfaceElevated)
                    .cornerRadius(theme.radii.medium)

                Spacer()
            }
        }
    }
}
