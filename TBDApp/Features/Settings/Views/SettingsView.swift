import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @Environment(\.theme) var theme

    var body: some View {
        AppScreenContainer {
            VStack(spacing: theme.spacing.xl) {
                // Header
                HStack {
                    Text("Settings")
                        .font(theme.typography.headingXL)
                        .foregroundColor(theme.colors.textPrimary)
                    Spacer()
                }

                // Content
                ScrollView {
                    VStack(spacing: theme.spacing.l) {
                        // Profile Section
                        AppCard {
                            VStack(alignment: .leading, spacing: theme.spacing.l) {
                                Text("Profile")
                                    .font(theme.typography.headingM)
                                    .foregroundColor(theme.colors.textPrimary)

                                AppTextField(
                                    "Username", placeholder: "Enter username",
                                    text: $viewModel.username)
                                AppTextField(
                                    "Email", placeholder: "Enter email", text: $viewModel.email)
                            }
                        }

                        // Preferences Section
                        AppCard {
                            VStack(alignment: .leading, spacing: theme.spacing.l) {
                                Text("Preferences")
                                    .font(theme.typography.headingM)
                                    .foregroundColor(theme.colors.textPrimary)

                                AppDropdown(
                                    label: "Currency",
                                    placeholder: "Select Currency",
                                    options: viewModel.currencies,
                                    selection: $viewModel.selectedCurrency
                                )

                                AppToggle(
                                    title: "Notifications", isOn: $viewModel.notificationsEnabled)
                            }
                        }

                        // App Info Section
                        AppCard {
                            VStack(alignment: .leading, spacing: theme.spacing.m) {
                                Text("About")
                                    .font(theme.typography.headingM)
                                    .foregroundColor(theme.colors.textPrimary)

                                HStack {
                                    Text("Version")
                                        .font(theme.typography.bodyM)
                                        .foregroundColor(theme.colors.textSecondary)
                                    Spacer()
                                    Text("1.0.0")
                                        .font(theme.typography.bodyM)
                                        .foregroundColor(theme.colors.textPrimary)
                                }
                            }
                        }

                        AppButton(title: "Save Changes", icon: "checkmark", style: .primary) {
                            // Save action
                        }
                        .padding(.top, theme.spacing.m)
                    }
                }
            }
        }
    }
}
