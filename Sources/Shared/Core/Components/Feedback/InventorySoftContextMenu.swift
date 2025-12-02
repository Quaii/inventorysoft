import SwiftUI

struct InventorySoftContextMenu<MenuContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let content: () -> MenuContent

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    if isPresented {
                        ZStack(alignment: .topLeading) {
                            // Invisible dismissal layer
                            Color.clear
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        isPresented = false
                                    }
                                }

                            // Menu Content
                            self.content()
                                .padding(8)
                                .background(Color(nsColor: .windowBackgroundColor))
                                .cornerRadius(8)
                                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .frame(width: 200)  // Fixed width for consistency
                                .position(
                                    x: geometry.size.width / 2, y: geometry.size.height + 10
                                )  // Position below anchor
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            )
    }
}

extension View {
    func inventorySoftContextMenu<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(InventorySoftContextMenu(isPresented: isPresented, content: content))
    }
}

struct ContextMenuItem: View {
    let icon: String
    let title: String
    let isDestructive: Bool
    let action: () -> Void

    init(icon: String, title: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.isDestructive = isDestructive
        self.action = action
    }

    var body: some View {

        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .frame(width: 20, alignment: .center)

                Text(title)
                    .font(.body)

                Spacer()
            }
            .foregroundColor(isDestructive ? .red : .primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
