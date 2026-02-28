import SwiftUI

// MARK: - Flowstate Spacing System
// 4pt grid. Every dimension is a multiple of 4.

public enum FlowSpacing {
    /// 2pt — hairline gaps.
    public static let xxxs: CGFloat = 2

    /// 4pt — minimum spacing unit.
    public static let xxs: CGFloat = 4

    /// 8pt — tight spacing (between related elements).
    public static let xs: CGFloat = 8

    /// 12pt — compact spacing.
    public static let sm: CGFloat = 12

    /// 16pt — standard spacing (default padding).
    public static let md: CGFloat = 16

    /// 20pt — comfortable spacing.
    public static let lg: CGFloat = 20

    /// 24pt — generous spacing.
    public static let xl: CGFloat = 24

    /// 32pt — section gaps.
    public static let xxl: CGFloat = 32

    /// 40pt — major section breaks.
    public static let xxxl: CGFloat = 40

    /// 48pt — screen-level spacing.
    public static let huge: CGFloat = 48
}

// MARK: - Corner Radius Tokens

public enum FlowRadius {
    /// 4pt — subtle rounding (tags, chips).
    public static let xs: CGFloat = 4

    /// 8pt — standard cards.
    public static let sm: CGFloat = 8

    /// 12pt — prominent cards.
    public static let md: CGFloat = 12

    /// 16pt — large cards, sheets.
    public static let lg: CGFloat = 16

    /// 20pt — modal sheets.
    public static let xl: CGFloat = 20

    /// Full circle.
    public static let full: CGFloat = .infinity
}

// MARK: - Size Tokens

public enum FlowSize {
    /// Standard touch target (44pt).
    public static let touchTarget: CGFloat = 44

    /// Compact touch target (36pt).
    public static let compactTouchTarget: CGFloat = 36

    /// Checkbox size (24pt).
    public static let checkbox: CGFloat = 24

    /// Small icon (16pt).
    public static let iconSmall: CGFloat = 16

    /// Standard icon (20pt).
    public static let iconMedium: CGFloat = 20

    /// Large icon (24pt).
    public static let iconLarge: CGFloat = 24

    /// Avatar/project icon (32pt).
    public static let avatar: CGFloat = 32

    /// Task row minimum height.
    public static let taskRowMinHeight: CGFloat = 52

    /// Section header height.
    public static let sectionHeaderHeight: CGFloat = 44
}

// MARK: - Padding Modifier

public struct FlowPadding: ViewModifier {
    let edges: Edge.Set
    let size: CGFloat

    public func body(content: Content) -> some View {
        content.padding(edges, size)
    }
}

public extension View {
    func flowPadding(_ edges: Edge.Set = .all, _ size: CGFloat = FlowSpacing.md) -> some View {
        modifier(FlowPadding(edges: edges, size: size))
    }
}
