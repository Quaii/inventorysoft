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
            Group {
                if isLoading {
                    ProgressView("Loading columns...")
                } else if let error = errorMessage {
                    ContentUnavailableView {
                        Label("Error Loading Columns", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(error)
                    } actions: {
                        Button("Retry") {
                            Task { await loadColumns() }
                        }
                    }
                } else {
                    List {
                        Section {
                            ForEach($columns) { $column in
                                HStack {
                                    // Drag handle (visual only for now)
                                    Image(systemName: "line.3.horizontal")
                                        .foregroundStyle(.secondary)

                                    // Column info
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(column.label)
                                            .font(.body)
                                        Text(column.field)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    // Visibility toggle
                                    Toggle("", isOn: $column.isVisible)
                                        .labelsHidden()
                                }
                            }
                            .onMove { from, to in
                                columns.move(fromOffsets: from, toOffset: to)
                            }
                        } header: {
                            Text(
                                "Configure which columns to display in your \(tableType.displayName) table. Drag to reorder."
                            )
                        }
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
