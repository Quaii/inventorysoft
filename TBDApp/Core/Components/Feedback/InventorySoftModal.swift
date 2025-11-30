import SwiftUI

struct InventorySoftModal<ModalContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let content: () -> ModalContent

    @Environment(\.theme) var theme

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isPresented)
                .blur(radius: isPresented ? 2 : 0)

            if isPresented {
                // Backdrop
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            isPresented = false
                        }
                    }
                    .transition(.opacity)

                // Modal Content
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text(title)
                            .font(theme.typography.headingM)
                            .foregroundColor(theme.colors.textPrimary)

                        Spacer()

                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(theme.colors.textSecondary)
                                .frame(width: 28, height: 28)
                                .background(theme.colors.surfaceElevated)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(theme.spacing.l)
                    .background(theme.colors.surfaceSecondary)

                    Divider().overlay(theme.colors.divider)

                    // Body
                    self.content()
                        .padding(theme.spacing.l)
                }
                .background(theme.colors.surfacePrimary)
                .cornerRadius(theme.radii.large)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: theme.radii.large)
                        .stroke(theme.colors.borderSubtle, lineWidth: 1)
                )
                .frame(maxWidth: 500)
                .padding(theme.spacing.l)
                .transition(.scale(scale: 0.95).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented)
    }
}

extension View {
    func inventorySoftModal<Content: View>(
        isPresented: Binding<Bool>,
        title: String,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(InventorySoftModal(isPresented: isPresented, title: title, content: content))
    }
}
