import SwiftUI

/// Individual KPI card component
struct KPICard: View {
    let kpi: DashboardKPI
    let onTap: () -> Void

    @Environment(\.theme) var theme
    @State private var isHovered = false

    var body: some View {
        Button(action: onTap) {
            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    // Icon and Title Row
                    HStack(spacing: 8) {
                        Image(systemName: kpi.metricKey.icon)
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)

                        Text(kpi.title)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        Spacer()
                    }

                    // Value
                    Text(kpi.value)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)

                    // Secondary Text (optional)
                    if let secondaryText = kpi.secondaryText {
                        Text(secondaryText)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(16)
            }
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}
