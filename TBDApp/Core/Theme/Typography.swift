import SwiftUI

struct AppTypography {
    // Using standard system fonts (SF Pro) to ensure clean, professional look.
    // Avoid custom tracking or widths unless specifically needed for numeric data.

    let headingXL = Font.system(size: 28, weight: .bold, design: .default)
    let headingL = Font.system(size: 24, weight: .semibold, design: .default)
    let headingM = Font.system(size: 18, weight: .semibold, design: .default)
    let headingS = Font.system(size: 16, weight: .semibold, design: .default)

    let bodyL = Font.system(size: 16, weight: .regular, design: .default)
    let bodyM = Font.system(size: 14, weight: .regular, design: .default)
    let bodyS = Font.system(size: 13, weight: .regular, design: .default)

    var body: Font { bodyM }

    // Caption for labels, timestamps, etc.
    let caption = Font.system(size: 12, weight: .medium, design: .default)

    // Numeric emphasis for KPIs - using rounded design can look good for numbers,
    // but keeping default for consistency with the "clean" requirement unless requested.
    let numericEmphasis = Font.system(size: 24, weight: .bold, design: .default)
    let numericLarge = Font.system(size: 32, weight: .bold, design: .default)

    // Aliases
    var h1: Font { headingXL }
    var h2: Font { headingL }
    var h3: Font { headingM }
}
