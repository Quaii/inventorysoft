import Charts
import SwiftUI

struct TotalItemsCard: View {
    let totalItems: Int
    let historicData: [ItemCountDataPoint]

    @Environment(\.theme) var theme

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: theme.spacing.m) {
                // Header
                HStack(alignment: .top) {
                    Text("Total Items")
                        .font(theme.typography.cardTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Spacer()

                    Text("All Time")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.textSecondary)
                }

                // Large Number
                Text("\(totalItems)")
                    .font(theme.typography.numericLarge)
                    .foregroundColor(theme.colors.textPrimary)

                Spacer()

                // Chart Area
                if historicData.isEmpty {
                    // Empty state chart placeholder
                    VStack(spacing: theme.spacing.s) {
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(0..<7) { index in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(theme.colors.surfaceSecondary)
                                    .frame(width: 20, height: CGFloat.random(in: 20...60))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)

                        Text("No data yet")
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.textSecondary)
                    }
                } else {
                    // Real chart
                    Chart(historicData) { point in
                        BarMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Items", point.count)
                        )
                        .foregroundStyle(theme.colors.accentPrimary)
                        .cornerRadius(4)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                .foregroundStyle(theme.colors.textSecondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine()
                                .foregroundStyle(theme.colors.borderSubtle)
                        }
                    }
                    .frame(height: 100)
                }
            }
        }
        .frame(minHeight: 260)
    }
}
