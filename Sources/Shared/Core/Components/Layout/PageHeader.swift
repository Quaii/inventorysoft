import SwiftUI

struct PageHeader<ActionContent: View>: View {
    let breadcrumbPage: String
    let title: String
    let subtitle: String
    let actionContent: ActionContent

    @Environment(\.theme) var theme

    init(
        breadcrumbPage: String,
        title: String,
        subtitle: String,
        @ViewBuilder actionContent: () -> ActionContent = { EmptyView() }
    ) {
        self.breadcrumbPage = breadcrumbPage
        self.title = title
        self.subtitle = subtitle
        self.actionContent = actionContent()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            // Breadcrumb
            Text("Pages / ")
                .foregroundColor(theme.colors.textSecondary)
                .font(theme.typography.meta)
                + Text(breadcrumbPage)
                .foregroundColor(theme.colors.textPrimary)
                .font(theme.typography.meta)
                .fontWeight(.semibold)

            // Title + Action Row
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    Text(title)
                        .font(theme.typography.pageTitle)
                        .foregroundColor(theme.colors.textPrimary)

                    Text(subtitle)
                        .font(theme.typography.body)
                        .foregroundColor(theme.colors.textSecondary)
                }

                Spacer()

                actionContent
            }
        }
    }
}

// Convenience initializer for no action
extension PageHeader where ActionContent == EmptyView {
    init(
        breadcrumbPage: String,
        title: String,
        subtitle: String
    ) {
        self.breadcrumbPage = breadcrumbPage
        self.title = title
        self.subtitle = subtitle
        self.actionContent = EmptyView()
    }
}
