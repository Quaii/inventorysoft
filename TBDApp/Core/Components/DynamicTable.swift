import SwiftUI

/// Dynamic table component that renders columns based on TableColumnConfig
struct DynamicTable<RowData: Identifiable>: View {
    let columns: [TableColumnConfig]
    let rows: [RowData]
    let rowContent: (RowData, TableColumnConfig) -> String
    let onRowTap: ((RowData) -> Void)?

    @Environment(\.theme) var theme

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
        VStack(spacing: 0) {
            headerView
            Divider().overlay(theme.colors.divider)
            rowsView
        }
        .background(theme.colors.surfacePrimary)
        .cornerRadius(theme.radii.medium)
        .overlay(
            RoundedRectangle(cornerRadius: theme.radii.medium)
                .stroke(theme.colors.borderSubtle, lineWidth: 1)
        )
    }

    private var headerView: some View {
        HStack(spacing: 0) {
            ForEach(columns) { column in
                Text(column.label)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.textSecondary)
                    .fontWeight(.semibold)
                    .frame(width: column.width ?? 100, alignment: .leading)
                    .padding(.horizontal, theme.spacing.s)
                    .padding(.vertical, theme.spacing.m)
            }
            Spacer()
        }
        .background(theme.colors.surfaceSecondary)
    }

    private var rowsView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(rows) { row in
                    rowView(for: row)
                }
            }
        }
    }

    private func rowView(for row: RowData) -> some View {
        HStack(spacing: 0) {
            ForEach(columns) { column in
                Text(rowContent(row, column))
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.textPrimary)
                    .frame(width: column.width ?? 100, alignment: .leading)
                    .padding(.horizontal, theme.spacing.s)
                    .padding(.vertical, theme.spacing.m)
            }
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onRowTap?(row)
        }
        .background(theme.colors.surfacePrimary)
        .overlay(alignment: .bottom) {
            Divider().overlay(theme.colors.borderSubtle)
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
