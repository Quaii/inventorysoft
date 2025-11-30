import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @Environment(\.theme) var theme
    @EnvironmentObject var appEnvironment: AppEnvironment

    @State private var isImporting = false
    @State private var isExportingJSON = false
    @State private var showingColumnConfigFor: TableType?

    var body: some View {
        AppScreenContainer {
            VStack(alignment: .leading, spacing: theme.spacing.xl) {
                // Page Header
                PageHeader(
                    breadcrumbPage: "Settings",
                    title: "Settings",
                    subtitle: "Configure application preferences"
                )

                // Content - Two rows of cards
                VStack(alignment: .leading, spacing: theme.spacing.xl) {
                    // Row 1: General, Data Management, Dashboard & Layout
                    HStack(alignment: .top, spacing: theme.spacing.xl) {
                        generalCard
                        dataManagementCard
                        dashboardLayoutCard
                    }

                    // Row 2: Appearance, Danger Zone
                    HStack(alignment: .top, spacing: theme.spacing.xl) {
                        appearanceCard
                        dangerZoneCard
                        Spacer()  // Third column placeholder
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
        .sheet(isPresented: $viewModel.showingCustomFieldManagement) {
            CustomFieldManagementView(customFieldRepository: viewModel.customFieldRepository)
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
        .sheet(item: $showingColumnConfigFor) { tableType in
            ColumnConfigurationView(
                tableType: tableType,
                columnConfigService: appEnvironment.columnConfigService
            )
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
    }

    // MARK: - General Card

    private var generalCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.l) {
                Text("General")
                    .font(theme.typography.cardTitle)
                    .foregroundColor(theme.colors.textPrimary)

                VStack(spacing: theme.spacing.m) {
                    VStack(alignment: .leading, spacing: theme.spacing.s) {
                        Text("Store Name")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                        AppTextField(
                            placeholder: "My Store",
                            text: .constant("Inventory Soft")
                        )
                    }

                    VStack(alignment: .leading, spacing: theme.spacing.s) {
                        Text("Currency")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                        AppDropdown(
                            options: UserPreferences.availableCurrencies.map { "\($0)" },
                            selection: Binding(
                                get: { viewModel.userPreferences.baseCurrency },
                                set: { newValue in
                                    Task {
                                        await viewModel.updateCurrency(newValue)
                                    }
                                }
                            )
                        )
                    }

                    VStack(alignment: .leading, spacing: theme.spacing.s) {
                        Text("Date Format")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                        AppDropdown(
                            options: UserPreferences.availableDateFormats,
                            selection: Binding(
                                get: { viewModel.userPreferences.dateFormat },
                                set: { newValue in
                                    Task {
                                        await viewModel.updateDateFormat(newValue)
                                    }
                                }
                            )
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 280)
    }

    // MARK: - Data Management Card

    private var dataManagementCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.l) {
                Text("Data Management")
                    .font(theme.typography.cardTitle)
                    .foregroundColor(theme.colors.textPrimary)

                VStack(spacing: theme.spacing.m) {
                    // Export Section
                    VStack(alignment: .leading, spacing: theme.spacing.s) {
                        Text("EXPORT")
                            .font(theme.typography.tableHeader)
                            .foregroundColor(theme.colors.textSecondary)

                        VStack(spacing: theme.spacing.s) {
                            AppButton(
                                title: "Export JSON",
                                icon: "square.and.arrow.up",
                                style: .secondary
                            ) {
                                isExportingJSON = true
                            }

                            AppButton(
                                title: "Export CSV",
                                icon: "doc.text",
                                style: .secondary
                            ) {
                                // CSV Export
                            }

                            AppButton(
                                title: "Export SQL",
                                icon: "database",
                                style: .secondary
                            ) {
                                // SQL Export
                            }
                        }
                    }

                    Divider().overlay(theme.colors.divider)

                    // Import Section
                    VStack(alignment: .leading, spacing: theme.spacing.s) {
                        Text("IMPORT")
                            .font(theme.typography.tableHeader)
                            .foregroundColor(theme.colors.textSecondary)

                        VStack(spacing: theme.spacing.s) {
                            AppButton(
                                title: "Import JSON",
                                icon: "square.and.arrow.down",
                                style: .secondary
                            ) {
                                isImporting = true
                            }

                            AppButton(
                                title: "Import CSV",
                                icon: "doc.text",
                                style: .secondary
                            ) {
                                // CSV Import
                            }

                            AppButton(
                                title: "Import SQL",
                                icon: "database",
                                style: .secondary
                            ) {
                                // SQL Import
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 280)
    }

    // MARK: - Dashboard & Layout Card

    private var dashboardLayoutCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.l) {
                Text("Dashboard & Layout")
                    .font(theme.typography.cardTitle)
                    .foregroundColor(theme.colors.textPrimary)

                VStack(spacing: theme.spacing.m) {
                    // Custom Fields
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Custom Fields")
                                .font(theme.typography.body)
                                .foregroundColor(theme.colors.textPrimary)
                            Text("Add custom fields to items, sales, and purchases")
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                        }

                        Spacer()

                        AppButton(
                            title: "Manage",
                            icon: "square.grid.3x3.square",
                            style: .secondary
                        ) {
                            viewModel.showingCustomFieldManagement = true
                        }
                    }

                    Divider().overlay(theme.colors.divider)

                    // Column Configuration
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Table Columns")
                                .font(theme.typography.body)
                                .foregroundColor(theme.colors.textPrimary)
                            Text("Configure visible columns for each table")
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                        }

                        Spacer()

                        Menu {
                            Button("Inventory Columns") {
                                showingColumnConfigFor = .inventory
                            }
                            Button("Sales Columns") {
                                showingColumnConfigFor = .sales
                            }
                            Button("Purchases Columns") {
                                showingColumnConfigFor = .purchases
                            }
                        } label: {
                            HStack(spacing: theme.spacing.s) {
                                Text("Configure")
                                Image(systemName: "chevron.down")
                            }
                            .font(theme.typography.body)
                            .foregroundColor(theme.colors.textPrimary)
                            .padding(.horizontal, theme.spacing.m)
                            .padding(.vertical, theme.spacing.s)
                            .background(theme.colors.surfaceElevated)
                            .cornerRadius(theme.radii.small)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 280)
    }

    // MARK: - Appearance Card

    private var appearanceCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.l) {
                Text("Appearance")
                    .font(theme.typography.cardTitle)
                    .foregroundColor(theme.colors.textPrimary)

                VStack(spacing: theme.spacing.m) {
                    VStack(alignment: .leading, spacing: theme.spacing.s) {
                        Text("Theme Mode")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                        AppDropdown(
                            options: ["Dark", "Light", "System"],
                            selection: Binding(
                                get: { viewModel.userPreferences.themeMode },
                                set: { newValue in
                                    Task {
                                        await viewModel.updateThemeMode(newValue)
                                        // Trigger app environment update
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
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Compact Mode")
                                .font(theme.typography.body).foregroundColor(
                                    theme.colors.textPrimary)
                            Text("Reduces vertical spacing throughout the app")
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)
                        }

                        Spacer()

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
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 180)
    }

    // MARK: - Danger Zone Card

    private var dangerZoneCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.l) {
                Text("Danger Zone")
                    .font(theme.typography.cardTitle)
                    .foregroundColor(theme.colors.error)

                VStack(alignment: .leading, spacing: theme.spacing.m) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reset Database")
                            .font(theme.typography.body)
                            .foregroundColor(theme.colors.textPrimary)
                        Text("Delete all items and sales history. This action cannot be undone.")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }

                    Spacer()

                    HStack {
                        Spacer()
                        AppButton(
                            title: "Reset",
                            icon: "trash",
                            style: .destructive
                        ) {
                            // Reset action with confirmation
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 180)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.card)
                .stroke(theme.colors.error.opacity(0.5), lineWidth: 1)
        )
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

// Identifiable extension for TableType
extension TableType: Identifiable {
    var id: String { rawValue }
}
