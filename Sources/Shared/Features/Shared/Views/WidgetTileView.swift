import SwiftUI

struct WidgetTileView<Content: View>: View {
    @Environment(\.theme) var theme

    let title: String
    let icon: String
    let size: DashboardWidgetSize
    let isEditing: Bool
    let onRemove: () -> Void
    let onContextMenu: (CGPoint) -> Void
    @ViewBuilder let content: () -> Content

    @State private var isHovered = false
    @State private var wobbleOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(theme.colors.accentSecondary)

                    Text(title)
                        .font(theme.typography.body)
                        .fontWeight(.medium)
                        .foregroundColor(theme.colors.textPrimary)
                        .lineLimit(1)

                    Spacer()

                    // Drag handle in edit mode
                    if isEditing {
                        Image(systemName: "line.3.horizontal")
                            .foregroundColor(theme.colors.textSecondary)
                            .font(.system(size: 12))
                    }
                }
                .padding(theme.spacing.m)

                Divider()
                    .overlay(theme.colors.borderSubtle)

                // Content
                content()
                    .padding(theme.spacing.m)
                    .opacity(isEditing ? 0.6 : 1.0)
            }
            .background(theme.colors.backgroundPrimary)
            .cornerRadius(theme.radii.medium)
            .shadow(
                color: isHovered ? Color.black.opacity(0.1) : Color.black.opacity(0.05),
                radius: isHovered ? 8 : 4,
                x: 0,
                y: isHovered ? 4 : 2
            )
            .overlay(
                RoundedRectangle(cornerRadius: theme.radii.medium)
                    .stroke(
                        isEditing ? theme.colors.accentPrimary.opacity(0.5) : theme.colors.backgroundPrimary,
                        lineWidth: isEditing ? 2 : 0
                    )
            )

            // Delete Button (Edit Mode)
            if isEditing {
                Button(action: onRemove) {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(theme.colors.error)
                        .background(Circle().fill(theme.colors.backgroundPrimary))
                }
                .buttonStyle(.plain)
                .offset(x: 8, y: -8)
            }
        }
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .rotationEffect(.degrees(isEditing ? wobbleOffset : 0))
        .animation(
            isEditing
                ? Animation.easeInOut(duration: 0.12).repeatForever(autoreverses: true)
                : .default,
            value: isEditing
        )
        .onAppear {
            if isEditing {
                wobbleOffset = Double.random(in: -1.0...1.0)
            }
        }
        .onChange(of: isEditing) { _, newValue in
            wobbleOffset = newValue ? Double.random(in: -1.0...1.0) : 0
        }
        .gesture(
            TapGesture(count: 1)
                .modifiers(.control)  // macOS right-click simulation for now, or just use contextMenu modifier on parent
                .onEnded { _ in
                    #if os(macOS)
                        let mouseLocation = NSEvent.mouseLocation
                        let point = CGPoint(x: mouseLocation.x, y: mouseLocation.y)
                        onContextMenu(point)
                    #endif
                }
        )
    }
}
