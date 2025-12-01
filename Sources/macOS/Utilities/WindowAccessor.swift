import AppKit
import SwiftUI

/// Helper to access and configure the underlying NSWindow
struct WindowAccessor: NSViewRepresentable {
    let configure: (NSWindow) -> Void

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                self.configure(window)
            }
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if let window = nsView.window {
            self.configure(window)
        }
    }
}

/// View modifier to configure window transparency
struct TransparentWindowModifier: ViewModifier {
    let opacity: Double

    func body(content: Content) -> some View {
        content
            .background(
                WindowAccessor { window in
                    // Enable global window transparency
                    window.isOpaque = false

                    // Set semi-transparent black background at window level
                    // This creates a global "tint" over whatever is behind the window
                    window.backgroundColor = NSColor.black.withAlphaComponent(1.0 - opacity)

                    // Make title bar transparent
                    window.titlebarAppearsTransparent = true
                    window.titleVisibility = .hidden

                    // Ensure window controls are visible
                    window.standardWindowButton(.closeButton)?.superview?.superview?.animator()
                        .alphaValue = 1.0

                    // Set the window's alpha value for global transparency
                    window.alphaValue = opacity
                })
    }
}

extension View {
    /// Make the window globally transparent with the specified opacity
    /// - Parameter opacity: Overall window opacity (0.0 = fully transparent, 1.0 = fully opaque)
    /// This applies transparency to the ENTIRE window, not just the background
    func transparentWindow(opacity: Double = 0.95) -> some View {
        self.modifier(TransparentWindowModifier(opacity: opacity))
    }
}
