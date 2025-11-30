import SwiftUI

struct AppSidebarItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let isCollapsed: Bool
    let action: () -> Void

    @Environment(\.theme) var theme
    @State private var isHovering = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: theme.spacing.m) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(iconColor)
                    .frame(width: 20)

                if !isCollapsed {
                    Text(label)
                        .font(.system(size: 14, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(textColor)

                    Spacer()
                }
            }
            .padding(.horizontal, isCollapsed ? theme.spacing.s : theme.spacing.m)
            .padding(.vertical, theme.spacing.s)
            .frame(maxWidth: .infinity, alignment: isCollapsed ? .center : .leading)
            .background(backgroundColor)
            .cornerRadius(theme.radii.small)
            .shadow(
                color: isSelected ? theme.colors.accentPrimary.opacity(0.1) : .clear,
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
    }

    private var backgroundColor: Color {
        if isSelected {
            return theme.colors.sidebarActiveBackground
        } else if isHovering {
            return theme.colors.highlight
        } else {
            return .clear
        }
    }

    private var iconColor: Color {
        isSelected ? theme.colors.accentPrimary : theme.colors.textSecondary
    }

    private var textColor: Color {
        isSelected ? theme.colors.textPrimary : theme.colors.textSecondary
    }
}
