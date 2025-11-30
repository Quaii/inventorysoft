import SwiftUI

struct AppTypography {
    // Using SF Pro Display/Text via system fonts

    // Page Titles (e.g. "Dashboard")
    // Professional page title style
    let pageTitle = Font.system(size: 28, weight: .bold)

    // Section Titles (e.g. "Inventory Overview")
    let sectionTitle = Font.system(size: 18, weight: .semibold)

    // Card Titles / Important Labels
    let cardTitle = Font.system(size: 16, weight: .semibold)

    // Card Subtitles
    let cardSubtitle = Font.system(size: 13, weight: .regular)

    // Table Headers (Caps)
    let tableHeader = Font.system(size: 11, weight: .semibold).smallCaps()

    // Body Text
    let body = Font.system(size: 13, weight: .regular)

    // Captions / Small Labels
    let caption = Font.system(size: 11, weight: .regular)

    // Meta (dates, breadcrumbs, small info)
    let meta = Font.system(size: 11, weight: .regular)

    // Button Labels
    let buttonLabel = Font.system(size: 13, weight: .semibold)

    // Numeric Emphasis (KPIs)
    let numericLarge = Font.system(size: 36, weight: .bold)
    let numericMedium = Font.system(size: 24, weight: .bold)

    // Legacy mapping for compatibility
    var headingXL: Font { pageTitle }
    var headingL: Font { sectionTitle }
    var headingM: Font { cardTitle }
    var headingS: Font { cardSubtitle }

    var bodyL: Font { body }
    var bodyM: Font { body }
    var bodyS: Font { caption }

    var numericEmphasis: Font { numericMedium }
    var numericBody: Font { body }

    var h1: Font { pageTitle }
    var h2: Font { sectionTitle }
    var h3: Font { cardTitle }
}
