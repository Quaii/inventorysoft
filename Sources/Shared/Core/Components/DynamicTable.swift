import SwiftUI

/// Dynamic table component that renders columns based on TableColumnConfig
struct DynamicTable<RowData: Identifiable>: View {
    let columns: [TableColumnConfig]
    let rows: [RowData]
    let rowContent: (RowData, TableColumnConfig) -> String
    let onRowTap: ((RowData) -> Void)?

    init(
        columns: [TableColumnConfig],
        rows: [RowData],
        rowContent: @escaping (RowData, TableColumnConfig) -> String,
        onRowTap: ((RowData) -> Void)? = nil
    ) {
        self.columns = columns.filter { $0.isVisible }.sorted { $0.sortOrder < $1.sortOrder }
        self.rows = rows
        self.rowContent = rowContent
        self.onRowTap = onRowTap
    }

    var body: some View {
        VStack(spacing: 12) {
            headerView
            rowsView
        }
    }

    private var headerView: some View {
        HStack(spacing: 0) {
            ForEach(columns) { column in
                Text(column.label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.semibold)
                    .frame(width: column.width ?? 100, alignment: .leading)
                    .padding(.horizontal, 8)
            }
            Spacer()
        }
        .padding(.horizontal, 12)
    }

    private var rowsView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(rows) { row in
                    rowView(for: row)
                }
            }
        }
    }

    private func rowView(for row: RowData) -> some View {
        GroupBox {
            HStack(spacing: 0) {
                ForEach(columns) { column in
                    Text(rowContent(row, column))
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(width: column.width ?? 100, alignment: .leading)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                }
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                onRowTap?(row)
            }
        }
    }
}

// Helper extension to format field values
extension DynamicTable {
    static func formatValue(_ value: Any?) -> String {
        guard let value = value else { return "-" }

        if let string = value as? String {
            return string.isEmpty ? "-" : string
        } else if let number = value as? any Numeric {
            return "\(number)"
        } else if let date = value as? Date {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        } else if let bool = value as? Bool {
            return bool ? "Yes" : "No"
        }

        return "\(value)"
    }
}
