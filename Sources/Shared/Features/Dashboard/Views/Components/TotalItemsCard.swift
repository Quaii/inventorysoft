import Charts
import SwiftUI

struct TotalItemsCard: View {
    let totalItems: Int
    let historicData: [ItemCountDataPoint]

    @Environment(\.theme) var theme

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack(alignment: .top) {
                    Text("Total Items")
                        .font(.headline)

                    Spacer()

                    Text("All Time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Large Number
                Text("\(totalItems)")
                    .font(.system(size: 48, weight: .bold))

                Spacer()

                // Chart Area
                if historicData.isEmpty {
                    // Empty state chart placeholder
                    VStack(spacing: 8) {
                        HStack(alignment: .bottom, spacing: 8) {
                            ForEach(0..<7) { index in
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(.secondarySystemFill))
                                    .frame(width: 20, height: CGFloat.random(in: 20...60))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)

                        Text("No data yet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    // Real chart
                    Chart(historicData) { point in
                        BarMark(
                            x: .value("Date", point.date, unit: .day),
                            y: .value("Items", point.count)
                        )
                        .foregroundStyle(.blue)
                        .cornerRadius(4)
                    }
                    .chartXAxis {
                        AxisMarks(values: .stride(by: .day)) { _ in
                            AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .chartYAxis {
                        AxisMarks { _ in
                            AxisGridLine()
                                .foregroundStyle(Color(nsColor: .separatorColor))
                        }
                    }
                    .frame(height: 100)
                }
            }
            .padding(4)
        }
        .frame(minHeight: 260)
    }
}
