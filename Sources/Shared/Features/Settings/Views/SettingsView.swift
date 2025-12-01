import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @Environment(\.theme) var theme
    @EnvironmentObject var appEnvironment: AppEnvironment

    @State private var isImporting = false
    @State private var isExportingJSON = false

    var body: some View {
        ZStack {
            // Background
            theme.colors.backgroundPrimary
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.xl) {
                    // Page Header
                    Text("Settings")
                        .font(theme.typography.pageTitle)
                        .foregroundColor(theme.colors.textPrimary)
                        .padding(.bottom, 8)

                    // Settings Content
                    VStack(spacing: 18) {
                        generalSection
                        appearanceSection
                        dashboardAnalyticsSection
                        dataManagementSection
                        dangerZoneSection
                    }
                    .frame(maxWidth: 1100)
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, theme.spacing.xxl)
                .padding(.top, theme.spacing.xl)
            }
            .inventorySoftScrollStyle()
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .sheet(isPresented: $viewModel.showingImportMapping) {
            if let url = viewModel.importURL {
                ImportMappingView(
                    importURL: url,
                    targetType: viewModel.importTargetType,
                    importMappingService: viewModel.importMappingService,
                    importProfileRepository: viewModel.importProfileRepository
                )
            }
        }
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json, .commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                viewModel.handleImportFile(url, targetType: .item)
            case .failure(let error):
                print("Import error: \(error)")
            }
        }
        .fileExporter(
            isPresented: $isExportingJSON,
            document: JSONDocument(text: "{\"mock\": \"data\"}"),
            contentType: .json,
            defaultFilename: "inventory_backup"
        ) { result in
            // Handle export result
        }
        .overlay {
            if viewModel.showingResetConfirmation {
                ResetDatabaseConfirmationView(
                    isPresented: $viewModel.showingResetConfirmation,
                    confirmationText: $viewModel.resetConfirmationText,
                    onConfirm: {
                        // Reset database action
                        print("Database reset confirmed")
                    }
                )
            }
        }
    }

    // MARK: - General Section

    private var generalSection: some View {
        SettingsSectionCard(
            title: "General",
            description: "Global app behavior that is not visual, and not per-page."
        ) {
            SettingsRowView(label: "Default Currency", showDivider: true) {
                SettingsPickerPill(
                    selectedValue: viewModel.userPreferences.baseCurrency,
                    options: UserPreferences.availableCurrencies
                ) { newValue in
                    Task {
                        await viewModel.updateCurrency(newValue)
                    }
                }
            }

            SettingsRowView(label: "Date Format", showDivider: true) {
                SettingsPickerPill(
                    selectedValue: viewModel.userPreferences.dateFormat,
                    options: UserPreferences.availableDateFormats
                ) { newValue in
                    Task {
                        await viewModel.updateDateFormat(newValue)
                    }
                }
            }

            SettingsRowView(label: "Number Format", showDivider: false) {
                SettingsPickerPill(
                    selectedValue: viewModel.userPreferences.numberFormattingLocale,
                    options: UserPreferences.availableNumberFormats
                ) { newValue in
                    Task {
                        await viewModel.updateNumberFormat(newValue)
                    }
                }
            }
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        SettingsSectionCard(
            title: "Appearance",
            description: "Visual style of the entire app."
        ) {
            SettingsRowView(label: "Theme", showDivider: true) {
                SettingsPickerPill(
                    selectedValue: viewModel.userPreferences.themeMode,
                    options: UserPreferences.availableThemeModes
                ) { newValue in
                    Task {
                        await viewModel.updateThemeMode(newValue)
                        do {
                            try await appEnvironment.savePreferences(viewModel.userPreferences)
                        } catch {
                            print("Failed to save preferences: \(error)")
                        }
                    }
                }
            }

            SettingsRowView(label: "Accent Color", showDivider: true) {
                SettingsPickerPill(
                    selectedValue: viewModel.userPreferences.accentColor,
                    options: UserPreferences.availableAccentColors
                ) { newValue in
                    Task {
                        await viewModel.updateAccentColor(newValue)
                        do {
                            try await appEnvironment.savePreferences(viewModel.userPreferences)
                        } catch {
                            print("Failed to save preferences: \(error)")
                        }
                    }
                }
            }

            SettingsRowView(
                label: "Compact Mode",
                helpText: "Reduces vertical spacing in tables and lists for denser information.",
                showDivider: true
            ) {
                Toggle(
                    "",
                    isOn: Binding(
                        get: { viewModel.userPreferences.compactMode },
                        set: { newValue in
                            Task {
                                await viewModel.updateCompactMode(newValue)
                                do {
                                    try await appEnvironment.savePreferences(
                                        viewModel.userPreferences)
                                } catch {
                                    print("Failed to save preferences: \(error)")
                                }
                            }
                        }
                    )
                )
                .labelsHidden()
            }

            SettingsRowView(label: "Sidebar", showDivider: false) {
                SettingsPickerPill(
                    selectedValue: viewModel.userPreferences.sidebarCollapseBehavior,
                    options: UserPreferences.availableSidebarBehaviors
                ) { newValue in
                    Task {
                        await viewModel.updateSidebarBehavior(newValue)
                    }
                }
            }
        }
    }

    // MARK: - Dashboard & Analytics Section

    private var dashboardAnalyticsSection: some View {
        SettingsSectionCard(
            title: "Dashboard & Analytics",
            description: "How the dashboard and analytics behave by default."
        ) {
            SettingsRowView(
                label: "Dashboard Layout on First Launch",
                helpText:
                    "'Empty' means no widgets by default. 'Recommended KPIs' initializes with helpful cards.",
                showDivider: true
            ) {
                SettingsPickerPill(
                    selectedValue: viewModel.userPreferences.dashboardInitialLayout,
                    options: UserPreferences.availableDashboardLayouts
                ) { newValue in
                    Task {
                        await viewModel.updateDashboardInitialLayout(newValue)
                    }
                }
            }

            SettingsRowView(
                label: "Allow Card Editing Mode",
                helpText:
                    "Enables 'edit mode' where dashboard cards can be rearranged and resized.",
                showDivider: true
            ) {
                Toggle(
                    "",
                    isOn: Binding(
                        get: { viewModel.userPreferences.allowDashboardEditing },
                        set: { newValue in
                            Task {
                                await viewModel.updateAllowDashboardEditing(newValue)
                            }
                        }
                    )
                )
                .labelsHidden()
            }

            SettingsRowView(label: "Default Analytics Date Range", showDivider: true) {
                SettingsPickerPill(
                    selectedValue: viewModel.userPreferences.defaultAnalyticsRange,
                    options: UserPreferences.availableAnalyticsRanges
                ) { newValue in
                    Task {
                        await viewModel.updateDefaultAnalyticsRange(newValue)
                    }
                }
            }

            SettingsRowView(label: "Default Time Interval", showDivider: false) {
                SettingsPickerPill(
                    selectedValue: viewModel.userPreferences.defaultAnalyticsInterval,
                    options: UserPreferences.availableAnalyticsIntervals
                ) { newValue in
                    Task {
                        await viewModel.updateDefaultAnalyticsInterval(newValue)
                    }
                }
            }
        }
    }

    // MARK: - Data Management Section

    private var dataManagementSection: some View {
        SettingsSectionCard(
            title: "Data Management",
            description: "Import, export, backup of local data."
        ) {
            VStack(alignment: .leading, spacing: 20) {
                Text("EXPORT")
                    .font(theme.typography.tableHeader)
                    .foregroundColor(theme.colors.textSecondary)

                HStack(spacing: 10) {
                    AppButton(
                        title: "Export CSV",
                        icon: "doc.text",
                        style: .secondary
                    ) {
                        // CSV Export
                    }

                    AppButton(
                        title: "Export JSON",
                        icon: "square.and.arrow.up",
                        style: .secondary
                    ) {
                        isExportingJSON = true
                    }
                }
            }
            .padding(.vertical, 12)

            Divider()
                .background(theme.colors.borderSubtle)

            // Import Section
            VStack(alignment: .leading, spacing: 10) {
                Text("IMPORT")
                    .font(theme.typography.tableHeader)
                    .foregroundColor(theme.colors.textSecondary)

                HStack(spacing: 10) {
                    AppButton(
                        title: "Import CSV",
                        icon: "doc.text",
                        style: .secondary
                    ) {
                        // CSV Import
                    }

                    AppButton(
                        title: "Import JSON",
                        icon: "square.and.arrow.down",
                        style: .secondary
                    ) {
                        isImporting = true
                    }
                }
            }
            .padding(.vertical, 12)

            Divider()
                .background(theme.colors.borderSubtle)

            SettingsRowView(
                label: "Backup Frequency",
                helpText: "Automatic backups of your complete database.",
                showDivider: true
            ) {
                SettingsPickerPill(
                    selectedValue: viewModel.userPreferences.backupFrequency,
                    options: UserPreferences.availableBackupFrequencies
                ) { newValue in
                    Task {
                        await viewModel.updateBackupFrequency(newValue)
                    }
                }
            }

            HStack {
                AppButton(
                    title: "Create Backup Now",
                    icon: "square.and.arrow.down.on.square",
                    style: .secondary
                ) {
                    // Manual backup
                }
            }
            .padding(.top, 4)
        }
    }

    // MARK: - Danger Zone Section

    private var dangerZoneSection: some View {
        SettingsSectionCard(
            title: "Danger Zone",
            isDangerZone: true
        ) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reset Database")
                        .font(theme.typography.body)
                        .fontWeight(.semibold)
                        .foregroundColor(theme.colors.textPrimary)
                    Text(
                        "Deletes all items, sales, purchases, images and settings. Requires explicit confirmation."
                    )
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()

                AppButton(
                    title: "Reset",
                    icon: "trash",
                    style: .destructive
                ) {
                    viewModel.showingResetConfirmation = true
                }
            }
            .padding(.vertical, 12)
        }
    }
}

// Helper for FileExporter
struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var text: String

    init(text: String) {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
            let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return FileWrapper(regularFileWithContents: data)
    }
}
