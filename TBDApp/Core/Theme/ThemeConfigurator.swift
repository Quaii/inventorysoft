import SwiftUI

#if os(iOS)
    import UIKit
#endif

class ThemeConfigurator {
    static func configure(_ theme: Theme) {
        #if os(iOS)
            // Force Dark Mode
            // Note: This is usually done via .preferredColorScheme(.dark) in SwiftUI,
            // but setting window overrideUserInterfaceStyle works for UIKit components too.

            // Tab Bar Appearance
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor(theme.colors.surfacePrimary)
            tabBarAppearance.shadowColor = UIColor(theme.colors.borderSubtle)

            // Item Appearance
            let itemAppearance = UITabBarItemAppearance()
            itemAppearance.normal.iconColor = UIColor(theme.colors.textSecondary)
            itemAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(theme.colors.textSecondary)
            ]

            itemAppearance.selected.iconColor = UIColor(theme.colors.accentPrimary)
            itemAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(theme.colors.accentPrimary)
            ]

            tabBarAppearance.stackedLayoutAppearance = itemAppearance
            tabBarAppearance.inlineLayoutAppearance = itemAppearance
            tabBarAppearance.compactInlineLayoutAppearance = itemAppearance

            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

            // Navigation Bar Appearance
            let navBarAppearance = UINavigationBarAppearance()
            navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.backgroundColor = UIColor(theme.colors.backgroundPrimary)
            navBarAppearance.shadowColor = UIColor(theme.colors.borderSubtle)

            navBarAppearance.titleTextAttributes = [
                .foregroundColor: UIColor(theme.colors.textPrimary),
                .font: UIFont.systemFont(ofSize: 17, weight: .semibold),
            ]
            navBarAppearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor(theme.colors.textPrimary),
                .font: UIFont.systemFont(ofSize: 34, weight: .bold),
            ]

            UINavigationBar.appearance().standardAppearance = navBarAppearance
            UINavigationBar.appearance().compactAppearance = navBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
            UINavigationBar.appearance().tintColor = UIColor(theme.colors.accentPrimary)

            // Global Tint
            UIView.appearance().tintColor = UIColor(theme.colors.accentPrimary)
        #endif
    }
}
