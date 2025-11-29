import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(alignment: .leading, spacing: theme.spacing.l) {
                Text("Settings")
                    .font(theme.typography.h2)
                    .foregroundColor(theme.colors.textPrimary)

                AppCard {
                    VStack(alignment: .leading, spacing: theme.spacing.m) {
                        Text("Appearance")
                            .font(theme.typography.h3)

                        AppToggle(title: "Dark Mode", isOn: $viewModel.isDarkMode)
                    }
                }

                Spacer()
            }
        }
    }
}
