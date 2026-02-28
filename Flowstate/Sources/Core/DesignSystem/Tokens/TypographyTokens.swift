import SwiftUI

// MARK: - Flowstate Typography
// SF Pro hierarchy with Dynamic Type support throughout.
// Monospaced variants for time/numbers.

public enum FlowTypography {

    // MARK: - Display

    /// Large screen titles (34pt bold).
    public static let largeTitle: Font = .largeTitle.weight(.bold)

    /// Section headers (28pt bold).
    public static let title: Font = .title.weight(.bold)

    /// Sub-section headers (22pt semibold).
    public static let title2: Font = .title2.weight(.semibold)

    /// Tertiary headers (20pt semibold).
    public static let title3: Font = .title3.weight(.semibold)

    // MARK: - Body

    /// Primary body text (17pt regular).
    public static let body: Font = .body

    /// Emphasized body text (17pt semibold).
    public static let bodyBold: Font = .body.weight(.semibold)

    /// Secondary info (15pt regular).
    public static let subheadline: Font = .subheadline

    /// Tertiary info (13pt regular).
    public static let footnote: Font = .footnote

    /// Small labels/metadata (11pt regular).
    public static let caption: Font = .caption

    /// Extra-small text (10pt regular).
    public static let caption2: Font = .caption2

    // MARK: - Monospaced (for timers, dates, numbers)

    /// Timer display (large monospaced).
    public static let timerDisplay: Font = .system(.largeTitle, design: .monospaced).weight(.light)

    /// Inline time/date (monospaced body).
    public static let monoBody: Font = .system(.body, design: .monospaced)

    /// Small monospaced (captions with numbers).
    public static let monoCaption: Font = .system(.caption, design: .monospaced)

    // MARK: - Rounded (for counts, badges)

    /// Badge count font.
    public static let badge: Font = .system(.caption2, design: .rounded).weight(.bold)

    /// Stat number (large rounded).
    public static let statNumber: Font = .system(.title, design: .rounded).weight(.bold)
}

// MARK: - Text Style Modifier

public struct FlowTextStyle: ViewModifier {
    let font: Font
    let color: Color

    public func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color)
    }
}

public extension View {
    func flowTextStyle(_ font: Font, color: Color = FlowColors.textPrimary) -> some View {
        modifier(FlowTextStyle(font: font, color: color))
    }
}
