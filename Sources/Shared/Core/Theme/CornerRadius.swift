import Foundation

struct AppCornerRadius {
    // Professional macOS corner radius specification
    let small: CGFloat = 8
    let medium: CGFloat = 16
    let large: CGFloat = 24

    // Cards (medium radius, polished cockpit style)
    let card: CGFloat = 20

    // Buttons, search fields, dropdowns (capsule/pill shape)
    let button: CGFloat = 999  // Full pill
    let input: CGFloat = 999  // Full pill for search/input fields
    let pill: CGFloat = 999  // Generic pill shape

    // Sidebar items (capsule for active state)
    let sidebarItem: CGFloat = 999
}
