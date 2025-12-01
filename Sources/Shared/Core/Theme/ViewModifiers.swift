import SwiftUI

// MARK: - Scrollbar Hiding
struct HideScrollbarModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
            content.scrollIndicators(.hidden)
        #else
            content.scrollIndicators(.hidden)
        #endif
    }
}

extension View {
    func hideScrollbars() -> some View {
        modifier(HideScrollbarModifier())
    }
}

// MARK: - Glassmorphism
struct GlassBackgroundModifier: ViewModifier {
    @Environment(\.theme) var theme
    var cornerRadius: CGFloat = 12

    func body(content: Content) -> some View {
        content
            .background(theme.colors.surfaceGlass)
            .cornerRadius(cornerRadius)
    }
}

extension View {
    func glassBackground(cornerRadius: CGFloat = 12) -> some View {
        modifier(GlassBackgroundModifier(cornerRadius: cornerRadius))
    }
}

// MARK: - InventorySoft Scroll Style
// Applies global scrollbar hiding and standard padding
struct InventorySoftScrollStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .hideScrollbars()
    }
}

extension View {
    func inventorySoftScrollStyle() -> some View {
        modifier(InventorySoftScrollStyleModifier())
    }
}
