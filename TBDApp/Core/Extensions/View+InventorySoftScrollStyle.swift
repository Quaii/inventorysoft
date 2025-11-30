import SwiftUI

extension View {
    /// Applies Inventory Soft's standard scroll style: hidden indicators with consistent padding
    func inventorySoftScrollStyle() -> some View {
        self.scrollIndicators(.hidden)
    }
}
