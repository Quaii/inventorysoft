import SwiftUI

struct InventorySoftModal<ModalContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let content: () -> ModalContent

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
                            .font(.title3)
                            .foregroundColor(.primary)

                        Spacer()

                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                isPresented = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.secondary)
                                .frame(width: 28, height: 28)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(24)
                    .background(Color(nsColor: .windowBackgroundColor))

                    Divider()

                    // Body
                    self.content()
                        .padding(24)
                }
                .background(Color(nsColor: .windowBackgroundColor))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .frame(maxWidth: 500)
                .padding(24)
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
