import SwiftUI

struct ColumnConfigurationView: View {
    let tableType: TableType
    let columnConfigService: ColumnConfigServiceProtocol

    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme

    @State private var columns: [TableColumnConfig] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    ProgressView("Loading columns...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = errorMessage {
                    VStack(spacing: theme.spacing.m) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundColor(theme.colors.error)
                        Text("Error Loading Columns")
                            .font(theme.typography.cardTitle)
                            .foregroundColor(theme.colors.textPrimary)
                        Text(error)
                            .font(theme.typography.body)
                            .foregroundColor(theme.colors.textSecondary)
                            .multilineTextAlignment(.center)

                        AppButton(title: "Retry") {
                            Task { await loadColumns() }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: theme.spacing.l) {
                            Text(
                                "Configure which columns to display in your \(tableType.displayName) table. Drag to reorder."
                            )
                            .font(theme.typography.body)
                            .foregroundColor(theme.colors.textSecondary)
                            .padding(.horizontal, theme.spacing.l)
                            .padding(.top, theme.spacing.m)

                            ForEach($columns) { $column in
                                ColumnConfigRow(column: $column)
                            }
                        }
                        .padding(.bottom, theme.spacing.xl)
                    }
                }
            }
            .navigationTitle("Configure \(tableType.displayName) Columns")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await saveConfiguration()
                        }
                    }
                    .disabled(isLoading)
                }
            }
        }
        .task {
            await loadColumns()
        }
    }

    private func loadColumns() async {
        isLoading = true
        errorMessage = nil

        do {
            columns = try await columnConfigService.getColumns(for: tableType)
            isLoading = false
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func saveConfiguration() async {
        do {
            try await columnConfigService.saveColumnConfiguration(columns, for: tableType)
            dismiss()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
        }
    }
}

struct ColumnConfigRow: View {
    @Binding var column: TableColumnConfig
    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            HStack(spacing: theme.spacing.m) {
                // Drag handle (visual only for now)
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(theme.colors.textMuted)

                // Column info
                VStack(alignment: .leading, spacing: 4) {
                    Text(column.label)
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textPrimary)
                    Text(column.field)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()

                // Visibility toggle
                Toggle("", isOn: $column.isVisible)
                    .labelsHidden()
            }
        }
        .padding(.horizontal, theme.spacing.l)
    }
}
