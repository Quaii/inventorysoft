import SwiftUI

struct DashboardConfigurationView: View {
    @Binding var isPresented: Bool
    @Environment(\.theme) var theme
    @Binding var widgets: [DashboardWidget]

    @State private var editedWidgets: [DashboardWidget] = []

    var body: some View {
        VStack(spacing: 0) {
            // Content

            Divider().overlay(theme.colors.divider)

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.l) {
                    ForEach(Array(editedWidgets.enumerated()), id: \.element.id) { index, widget in
                        WidgetConfigRow(
                            widget: binding(for: widget),
                            index: index,
                            totalCount: editedWidgets.count,
                            onMoveUp: { moveWidget(from: index, to: index - 1) },
                            onMoveDown: { moveWidget(from: index, to: index + 1) }
                        )
                    }

                    // Reset Button
                    AppButton(
                        title: "Reset to Default Layout",
                        icon: "arrow.counterclockwise",
                        style: .secondary
                    ) {
                        resetToDefaults()
                    }
                    .padding(.horizontal, theme.spacing.l)
                }
                .padding(.vertical, theme.spacing.l)
            }

            // Footer
            Divider().overlay(theme.colors.divider)

            HStack {
                AppButton(title: "Cancel", style: .ghost) {
                    isPresented = false
                }

                Spacer()

                AppButton(title: "Save Changes", style: .primary) {
                    saveConfiguration()
                    isPresented = false
                }
            }
            .padding(theme.spacing.l)
            .background(theme.colors.backgroundPrimary)
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

    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(spacing: theme.spacing.m) {
                HStack(spacing: theme.spacing.m) {
                    // Reorder Controls
                    VStack(spacing: 4) {
                        Button(action: onMoveUp) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(
                                    index > 0 ? theme.colors.textPrimary : theme.colors.textMuted
                                )
                                .frame(width: 24, height: 24)
                                .background(theme.colors.surfaceElevated)
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        .disabled(index == 0)

                        Button(action: onMoveDown) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(
                                    index < totalCount - 1
                                        ? theme.colors.textPrimary : theme.colors.textMuted
                                )
                                .frame(width: 24, height: 24)
                                .background(theme.colors.surfaceElevated)
                                .cornerRadius(4)
                        }
                        .buttonStyle(.plain)
                        .disabled(index == totalCount - 1)
                    }

                    // Icon
                    Image(systemName: widget.type.icon)
                        .font(.system(size: 20))
                        .foregroundColor(theme.colors.accentPrimary)
                        .frame(width: 40, height: 40)
                        .background(theme.colors.surfaceElevated)
                        .cornerRadius(8)

                    // Title
                    VStack(alignment: .leading, spacing: 2) {
                        Text(widget.metric.displayName)
                            .font(theme.typography.cardTitle)
                            .foregroundColor(theme.colors.textPrimary)

                        Text(widget.type.icon)
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }

                    Spacer()

                    // Visibility Toggle
                    Toggle("", isOn: $widget.isVisible)
                        .labelsHidden()
                }

                if widget.isVisible {
                    Divider().overlay(theme.colors.divider)

                    VStack(alignment: .leading, spacing: theme.spacing.m) {
                        // Size Selector
                        VStack(alignment: .leading, spacing: theme.spacing.s) {
                            Text("SIZE")
                                .font(theme.typography.tableHeader)
                                .foregroundColor(theme.colors.textSecondary)

                            Picker("Size", selection: $widget.size) {
                                ForEach(WidgetSize.allCases, id: \.self) { size in
                                    Text(size.rawValue.capitalized).tag(size)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        // Chart Type Selector (if applicable)
                        if widget.type == .chart {
                            VStack(alignment: .leading, spacing: theme.spacing.s) {
                                Text("CHART TYPE")
                                    .font(theme.typography.tableHeader)
                                    .foregroundColor(theme.colors.textSecondary)

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
        }
        .padding(.horizontal, theme.spacing.l)
    }
}
