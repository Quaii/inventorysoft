import Foundation

struct AppSpacing {
    let xxs: CGFloat
    let xs: CGFloat
    let s: CGFloat
    let m: CGFloat
    let l: CGFloat
    let xl: CGFloat
    let xxl: CGFloat

    init(compactMode: Bool = false) {
        let multiplier: CGFloat = compactMode ? 0.8 : 1.0

        self.xxs = 4 * multiplier
        self.xs = 6 * multiplier
        self.s = 8 * multiplier
        self.m = 12 * multiplier
        self.l = 16 * multiplier
        self.xl = 24 * multiplier
        self.xxl = 32 * multiplier
    }
}
