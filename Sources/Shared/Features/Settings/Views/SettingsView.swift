import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        NavigationStack {
            Form {
                // General Section
                Section("General") {
                    Picker(
                        "Default Currency",
                        selection: Binding(
                            get: { viewModel.userPreferences.baseCurrency },
                            set: { newValue in
                                Task { await viewModel.updateCurrency(newValue) }
                            }
                        )
                    ) {
                        ForEach(UserPreferences.availableCurrencies, id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }

                    Picker(
                        "Date Format",
                        selection: Binding(
                            get: { viewModel.userPreferences.dateFormat },
                            set: { newValue in
                                Task { await viewModel.updateDateFormat(newValue) }
                            }
                        )
                    ) {
                        ForEach(UserPreferences.availableDateFormats, id: \.self) { format in
                            Text(format).tag(format)
                        }
                    }

                    Picker(
                        "Number Format",
                        selection: Binding(
                            get: { viewModel.userPreferences.numberFormattingLocale },
                            set: { newValue in
                                Task { await viewModel.updateNumberFormat(newValue) }
                            }
                        )
                    ) {
                        ForEach(UserPreferences.availableNumberFormats, id: \.self) { format in
                            Text(format).tag(format)
                        }
                    }
                }

                // Appearance Section
                Section("Appearance") {
                    Picker(
                        "Theme",
                        selection: Binding(
                            get: { viewModel.userPreferences.themeMode },
                            set: { newValue in
                                Task { await viewModel.updateThemeMode(newValue) }
                            }
                        )
                    ) {
                        ForEach(UserPreferences.availableThemeModes, id: \.self) { mode in
                            Text(mode).tag(mode)
                        }
                    }

                    Picker(
                        "Accent Color",
                        selection: Binding(
                            get: { viewModel.userPreferences.accentColor },
                            set: { newValue in
                                Task { await viewModel.updateAccentColor(newValue) }
                            }
                        )
                    ) {
                        ForEach(UserPreferences.availableAccentColors, id: \.self) { color in
                            Text(color).tag(color)
                        }
                    }

                    Toggle(
                        "Compact Mode",
                        isOn: Binding(
                            get: { viewModel.userPreferences.compactMode },
                            set: { newValue in
                                Task { await viewModel.updateCompactMode(newValue) }
                            }
                        ))

                    Picker(
                        "Sidebar",
                        selection: Binding(
                            get: { viewModel.userPreferences.sidebarCollapseBehavior },
                            set: { newValue in
                                Task { await viewModel.updateSidebarBehavior(newValue) }
                            }
                        )
                    ) {
                        ForEach(UserPreferences.availableSidebarBehaviors, id: \.self) { behavior in
                            Text(behavior).tag(behavior)
                        }
                    }
                }

                // Dashboard & Analytics Section
                Section("Dashboard & Analytics") {
                    Picker(
                        "Dashboard Layout on First Launch",
                        selection: Binding(
                            get: { viewModel.userPreferences.dashboardInitialLayout },
                            set: { newValue in
                                Task {
                                    await viewModel.updateDashboardInitialLayout(newValue)
                                }
                            }
                        )
                    ) {
                        ForEach(UserPreferences.availableDashboardLayouts, id: \.self) { layout in
                            Text(layout).tag(layout)
                        }
                    }

                    Toggle(
                        "Allow Card Editing Mode",
                        isOn: Binding(
                            get: { viewModel.userPreferences.allowDashboardEditing },
                            set: { newValue in
                                Task {
                                    await viewModel.updateAllowDashboardEditing(newValue)
                                }
                            }
                        ))
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
        }
    }
}
