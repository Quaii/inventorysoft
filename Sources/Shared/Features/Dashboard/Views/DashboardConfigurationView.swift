import SwiftUI

struct DashboardConfigurationView: View {
    @Binding var isPresented: Bool
    @Environment(\.theme) var theme
    @Binding var widgets: [DashboardWidget]

    @State private var editedWidgets: [DashboardWidget] = []

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(Array(editedWidgets.enumerated()), id: \.element.id) { index, widget in
                        WidgetConfigRow(
                            widget: binding(for: widget),
                            index: index,
                            totalCount: editedWidgets.count,
                            onMoveUp: { moveWidget(from: index, to: index - 1) },
                            onMoveDown: { moveWidget(from: index, to: index + 1) }
                        )
                    }
                }

                Section {
                    Button(role: .destructive) {
                        resetToDefaults()
                    } label: {
                        Label("Reset to Default Layout", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle("Configure Dashboard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Changes") {
                        saveConfiguration()
                        isPresented = false
                    }
                }
            }
        }
        .onAppear {
            editedWidgets = widgets
        }
    }

    private func binding(for widget: DashboardWidget) -> Binding<DashboardWidget> {
        guard let index = editedWidgets.firstIndex(where: { $0.id == widget.id }) else {
            fatalError("Widget not found")
        }
        return $editedWidgets[index]
    }

    private func moveWidget(from source: Int, to destination: Int) {
        guard destination >= 0 && destination < editedWidgets.count else { return }
        let widget = editedWidgets.remove(at: source)
        editedWidgets.insert(widget, at: destination)
        // Update sortOrder
        for (index, _) in editedWidgets.enumerated() {
            editedWidgets[index].sortOrder = index
        }
    }

    private func resetToDefaults() {
        // Reset to default widget configuration
        // This would typically come from a service/repository
        editedWidgets = widgets  // For now, just reload original
    }

    private func saveConfiguration() {
        widgets = editedWidgets
    }
}

struct WidgetConfigRow: View {
    @Binding var widget: DashboardWidget
    let index: Int
    let totalCount: Int
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void

    var body: some View {
        GroupBox {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    // Reorder Controls
                    VStack(spacing: 4) {
                        Button(action: onMoveUp) {
                            Image(systemName: "chevron.up")
                                .font(.caption.bold())
                                .frame(width: 24, height: 24)
                                .background(Color(.secondarySystemFill))
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        .disabled(index == 0)

                        Button(action: onMoveDown) {
                            Image(systemName: "chevron.down")
                                .font(.caption.bold())
                                .frame(width: 24, height: 24)
                                .background(Color(.secondarySystemFill))
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        .disabled(index == totalCount - 1)
                    }

                    // Icon
                    Image(systemName: widget.type.icon)
                        .font(.title3)
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color(.secondarySystemFill))
                        .cornerRadius(8)

                    // Title
                    VStack(alignment: .leading, spacing: 2) {
                        Text(widget.metric.displayName)
                            .font(.headline)

                        Text(widget.type.icon)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Visibility Toggle
                    Toggle("", isOn: $widget.isVisible)
                        .labelsHidden()
                }

                if widget.isVisible {
                    Divider()

                    VStack(alignment: .leading, spacing: 12) {
                        // Size Selector
                        VStack(alignment: .leading, spacing: 8) {
                            Text("SIZE")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Picker("Size", selection: $widget.size) {
                                ForEach(WidgetSize.allCases, id: \.self) { size in
                                    Text(size.rawValue.capitalized).tag(size)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        // Chart Type Selector (if applicable)
                        if widget.type == .chart {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("CHART TYPE")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Picker("Chart Type", selection: $widget.chartType) {
                                    ForEach([ChartType.bar, .line, .area, .donut], id: \.self) {
                                        type in
                                        HStack {
                                            Image(systemName: type.icon)
                                            Text(type.displayName)
                                        }.tag(type)
                                    }
                                }
                                .pickerStyle(.menu)
                            }
                        }
                    }
                }
            }
            .padding(4)
        }
    }
}
