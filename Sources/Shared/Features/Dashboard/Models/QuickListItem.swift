import Foundation

/// Model for quick list items in Recent Sales/Purchases/Items cards
struct QuickListItem: Identifiable {
    let id: UUID
    let icon: String
    let title: String
    let subtitle: String
    let value: String

    init(id: UUID = UUID(), icon: String, title: String, subtitle: String, value: String) {
        self.id = id
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.value = value
    }
}
