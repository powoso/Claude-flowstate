import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Flowstate Color System
// Calm, focused palette. Primary accent is warm indigo.
// All colors support light/dark mode and high contrast.

public enum FlowColors {

    // MARK: - Brand

    /// Warm indigo — the signature Flowstate accent.
    public static let accentFallback = Color(
        light: Color(red: 0.33, green: 0.28, blue: 0.85),
        dark: Color(red: 0.50, green: 0.45, blue: 1.0)
    )

    // MARK: - Semantic

    public static let background = Color(
        light: Color(red: 0.98, green: 0.98, blue: 0.98),
        dark: Color(red: 0.08, green: 0.08, blue: 0.08)
    )

    public static let secondaryBackground = Color(
        light: .white,
        dark: Color(red: 0.12, green: 0.12, blue: 0.12)
    )

    public static let tertiaryBackground = Color(
        light: Color(red: 0.95, green: 0.95, blue: 0.95),
        dark: Color(red: 0.16, green: 0.16, blue: 0.16)
    )

    public static let groupedBackground = Color(
        light: Color(red: 0.95, green: 0.95, blue: 0.97),
        dark: Color(red: 0.06, green: 0.06, blue: 0.06)
    )

    // MARK: - Text

    public static let textPrimary = Color(
        light: Color(red: 0.10, green: 0.10, blue: 0.10),
        dark: Color(red: 0.95, green: 0.95, blue: 0.95)
    )

    public static let textSecondary = Color(
        light: Color(red: 0.40, green: 0.40, blue: 0.40),
        dark: Color(red: 0.60, green: 0.60, blue: 0.60)
    )

    public static let textTertiary = Color(
        light: Color(red: 0.60, green: 0.60, blue: 0.60),
        dark: Color(red: 0.40, green: 0.40, blue: 0.40)
    )

    // MARK: - Priority Colors

    public static let priorityUrgent = Color(
        light: Color(red: 0.91, green: 0.25, blue: 0.20),
        dark: Color(red: 1.0, green: 0.40, blue: 0.35)
    )

    public static let priorityHigh = Color(
        light: Color(red: 1.0, green: 0.58, blue: 0.0),
        dark: Color(red: 1.0, green: 0.68, blue: 0.25)
    )

    public static let priorityMedium = Color(
        light: Color(red: 0.25, green: 0.60, blue: 1.0),
        dark: Color(red: 0.45, green: 0.72, blue: 1.0)
    )

    public static let priorityLow = Color(
        light: Color(red: 0.55, green: 0.55, blue: 0.55),
        dark: Color(red: 0.50, green: 0.50, blue: 0.50)
    )

    // MARK: - Status

    public static let success = Color(
        light: Color(red: 0.20, green: 0.78, blue: 0.35),
        dark: Color(red: 0.30, green: 0.86, blue: 0.46)
    )

    public static let warning = Color(
        light: Color(red: 1.0, green: 0.76, blue: 0.0),
        dark: Color(red: 1.0, green: 0.84, blue: 0.25)
    )

    public static let destructive = Color(
        light: Color(red: 0.91, green: 0.25, blue: 0.20),
        dark: Color(red: 1.0, green: 0.40, blue: 0.35)
    )

    // MARK: - Project Palette (curated, user-assignable)

    public static let projectPalette: [Color] = [
        Color(red: 0.33, green: 0.28, blue: 0.85),  // Indigo
        Color(red: 0.91, green: 0.25, blue: 0.20),   // Red
        Color(red: 1.0, green: 0.58, blue: 0.0),     // Orange
        Color(red: 1.0, green: 0.76, blue: 0.0),     // Yellow
        Color(red: 0.20, green: 0.78, blue: 0.35),   // Green
        Color(red: 0.0, green: 0.74, blue: 0.78),    // Teal
        Color(red: 0.25, green: 0.60, blue: 1.0),    // Blue
        Color(red: 0.62, green: 0.35, blue: 0.90),   // Purple
        Color(red: 0.90, green: 0.35, blue: 0.62),   // Pink
        Color(red: 0.45, green: 0.35, blue: 0.28),   // Brown
    ]

    // MARK: - Separator

    public static let separator = Color(
        light: Color(red: 0.85, green: 0.85, blue: 0.85),
        dark: Color(red: 0.22, green: 0.22, blue: 0.22)
    )

    public static let thinSeparator = Color(
        light: Color(red: 0.90, green: 0.90, blue: 0.90),
        dark: Color(red: 0.18, green: 0.18, blue: 0.18)
    )
}

// MARK: - Adaptive Color Initializer

extension Color {
    /// Creates a dynamic color that adapts between light and dark mode.
    init(light lightColor: Color, dark darkColor: Color) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(darkColor)
                : UIColor(lightColor)
        })
        #elseif canImport(AppKit)
        self.init(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .vibrantDark]) != nil
                ? NSColor(darkColor)
                : NSColor(lightColor)
        })
        #endif
    }
}
