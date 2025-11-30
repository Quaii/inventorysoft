import SwiftUI

/// Grid layout for KPI cards at the top of the dashboard
struct KPIGridView: View {
    let kpis: [DashboardKPI]
    let onKPITap: (DashboardKPI) -> Void

    @Environment(\.theme) var theme

    // Responsive columns: 3 on wide, 2 on medium, 1 on narrow
    private var columns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 200, maximum: 400), spacing: theme.spacing.l)
        ]
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: theme.spacing.l) {
            ForEach(kpis.filter { $0.isVisible }.sorted(by: { $0.sortOrder < $1.sortOrder })) {
                kpi in
                KPICard(
                    kpi: kpi,
                    onTap: {
                        onKPITap(kpi)
                    })
            }
        }
    }
}
