import SwiftUI

struct AppSidebarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.theme) var theme
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: theme.spacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20, height: 20)

                Text(label)
                    .font(theme.typography.body)
                    .fontWeight(isSelected ? .semibold : .medium)

                Spacer()

                if isSelected {
                    Circle()
                        .fill(theme.colors.accentPrimary)
                        .frame(width: 6, height: 6)
                        .shadow(
                            color: theme.colors.accentPrimary.opacity(0.5), radius: 4, x: 0, y: 0)
                }
            }
            .padding(.horizontal, theme.spacing.l)
            .padding(.vertical, theme.spacing.s)
            .background(
                RoundedRectangle(cornerRadius: theme.radii.medium)
                    .fill(backgroundColor)
            )
            .foregroundColor(foregroundColor)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return theme.colors.accentPrimary.opacity(0.15)
        } else if isHovering {
            return theme.colors.surfaceSecondary
        } else {
            return .clear
        }
    }

    private var foregroundColor: Color {
        if isSelected {
            return theme.colors.accentPrimary
        } else if isHovering {
            return theme.colors.textPrimary
        } else {
            return theme.colors.textSecondary
        }
    }
}
