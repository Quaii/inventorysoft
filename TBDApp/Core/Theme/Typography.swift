import SwiftUI

struct AppTypography {
    let headingXL = Font.system(size: 28, weight: .semibold)
    let headingL = Font.system(size: 22, weight: .semibold)
    let headingM = Font.system(size: 17, weight: .semibold)
    let headingS = Font.system(size: 15, weight: .semibold)  // Added for compatibility if needed, or map to bodyM bold

    let bodyL = Font.system(size: 17, weight: .regular)
    let bodyM = Font.system(size: 15, weight: .regular)
    let bodyS = Font.system(size: 13, weight: .regular)

    var body: Font { bodyM }
    let caption = Font.system(size: 11, weight: .medium).width(.expanded)  // Tracking loose

    let numericEmphasis = Font.system(size: 20, weight: .bold)  // Tracking tight handled in view modifiers if needed, or custom Font extension

    // Aliases
    var h1: Font { headingXL }
    var h2: Font { headingL }
    var h3: Font { headingM }
}
