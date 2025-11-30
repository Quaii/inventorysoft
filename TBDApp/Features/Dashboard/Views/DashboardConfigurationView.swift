import SwiftUI

struct DashboardConfigurationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.theme) var theme
    @Binding var widgets: [DashboardWidget]

    @State private var editedWidgets: [DashboardWidget] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: theme.spacing.l) {
                    Text(
                        "Configure your dashboard by toggling widgets, changing their metrics, and reordering them."
                    )
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textSecondary)
                    .padding(.horizontal, theme.spacing.l)

                    ForEach($editedWidgets) { $widget in
                        WidgetConfigRow(widget: $widget)
                    }
                }
                .padding(.vertical, theme.spacing.l)
            }
            .navigationTitle("Configure Dashboard")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveConfiguration()
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            editedWidgets = widgets
        }
    }

    private func saveConfiguration() {
        widgets = editedWidgets
    }
}

struct WidgetConfigRow: View {
    @Binding var widget: DashboardWidget
    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(spacing: theme.spacing.m) {
                HStack {
                    Image(systemName: widget.type.icon)
                        .foregroundColor(theme.colors.accentPrimary)

                    Text(widget.metric.displayName)
                        .font(theme.typography.bodyM)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    Toggle("", isOn: $widget.isVisible)
                        .labelsHidden()
                }

                if widget.isVisible {
                    Divider()

                    VStack(alignment: .leading, spacing: theme.spacing.s) {
                        Text("Size")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)

                        Picker("Size", selection: $widget.size) {
                            ForEach(WidgetSize.allCases, id: \.self) { size in
                                Text(size.rawValue.capitalized).tag(size)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    if widget.type == .chart {
                        VStack(alignment: .leading, spacing: theme.spacing.s) {
                            Text("Chart Type")
                                .font(theme.typography.caption)
                                .foregroundColor(theme.colors.textSecondary)

                            Picker("Chart Type", selection: $widget.chartType) {
                                ForEach([ChartType.bar, .line, .area], id: \.self) { type in
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
        .padding(.horizontal, theme.spacing.l)
    }
}
