import SwiftUI

// MARK: - Flowstate Color System
// Calm, focused palette. Primary accent is warm indigo.
// All colors support light/dark mode and high contrast.

public enum FlowColors {

    // MARK: - Brand

    /// Warm indigo — the signature Flowstate accent.
    public static let accent = Color("FlowAccent", bundle: .module)

    /// Fallback programmatic accent (warm indigo).
    public static let accentFallback = Color(
        light: .init(red: 0.33, green: 0.28, blue: 0.85),
        dark: .init(red: 0.50, green: 0.45, blue: 1.0)
    )

    // MARK: - Semantic

    public static let background = Color(
        light: .init(white: 0.98),
        dark: .init(white: 0.08)
    )

    public static let secondaryBackground = Color(
        light: .init(white: 1.0),
        dark: .init(white: 0.12)
    )

    public static let tertiaryBackground = Color(
        light: .init(white: 0.95),
        dark: .init(white: 0.16)
    )

    public static let groupedBackground = Color(
        light: .init(red: 0.95, green: 0.95, blue: 0.97),
        dark: .init(white: 0.06)
    )

    // MARK: - Text

    public static let textPrimary = Color(
        light: .init(white: 0.10),
        dark: .init(white: 0.95)
    )

    public static let textSecondary = Color(
        light: .init(white: 0.40),
        dark: .init(white: 0.60)
    )

    public static let textTertiary = Color(
        light: .init(white: 0.60),
        dark: .init(white: 0.40)
    )

    // MARK: - Priority Colors

    public static let priorityUrgent = Color(
        light: .init(red: 0.91, green: 0.25, blue: 0.20),
        dark: .init(red: 1.0, green: 0.40, blue: 0.35)
    )

    public static let priorityHigh = Color(
        light: .init(red: 1.0, green: 0.58, blue: 0.0),
        dark: .init(red: 1.0, green: 0.68, blue: 0.25)
    )

    public static let priorityMedium = Color(
        light: .init(red: 0.25, green: 0.60, blue: 1.0),
        dark: .init(red: 0.45, green: 0.72, blue: 1.0)
    )

    public static let priorityLow = Color(
        light: .init(white: 0.55),
        dark: .init(white: 0.50)
    )

    // MARK: - Status

    public static let success = Color(
        light: .init(red: 0.20, green: 0.78, blue: 0.35),
        dark: .init(red: 0.30, green: 0.86, blue: 0.46)
    )

    public static let warning = Color(
        light: .init(red: 1.0, green: 0.76, blue: 0.0),
        dark: .init(red: 1.0, green: 0.84, blue: 0.25)
    )

    public static let destructive = Color(
        light: .init(red: 0.91, green: 0.25, blue: 0.20),
        dark: .init(red: 1.0, green: 0.40, blue: 0.35)
    )

    // MARK: - Project Palette (curated, user-assignable)

    public static let projectPalette: [Color] = [
        Color(light: .init(red: 0.33, green: 0.28, blue: 0.85), dark: .init(red: 0.50, green: 0.45, blue: 1.0)),   // Indigo
        Color(light: .init(red: 0.91, green: 0.25, blue: 0.20), dark: .init(red: 1.0, green: 0.40, blue: 0.35)),    // Red
        Color(light: .init(red: 1.0, green: 0.58, blue: 0.0), dark: .init(red: 1.0, green: 0.68, blue: 0.25)),      // Orange
        Color(light: .init(red: 1.0, green: 0.76, blue: 0.0), dark: .init(red: 1.0, green: 0.84, blue: 0.25)),      // Yellow
        Color(light: .init(red: 0.20, green: 0.78, blue: 0.35), dark: .init(red: 0.30, green: 0.86, blue: 0.46)),   // Green
        Color(light: .init(red: 0.0, green: 0.74, blue: 0.78), dark: .init(red: 0.20, green: 0.84, blue: 0.88)),    // Teal
        Color(light: .init(red: 0.25, green: 0.60, blue: 1.0), dark: .init(red: 0.45, green: 0.72, blue: 1.0)),     // Blue
        Color(light: .init(red: 0.62, green: 0.35, blue: 0.90), dark: .init(red: 0.75, green: 0.50, blue: 1.0)),    // Purple
        Color(light: .init(red: 0.90, green: 0.35, blue: 0.62), dark: .init(red: 1.0, green: 0.50, blue: 0.72)),    // Pink
        Color(light: .init(red: 0.45, green: 0.35, blue: 0.28), dark: .init(red: 0.65, green: 0.55, blue: 0.48)),   // Brown
    ]

    // MARK: - Separator

    public static let separator = Color(
        light: .init(white: 0.85),
        dark: .init(white: 0.22)
    )

    public static let thinSeparator = Color(
        light: .init(white: 0.90),
        dark: .init(white: 0.18)
    )
}

// MARK: - Adaptive Color Initializer

extension Color {
    init(light: Color.Resolved, dark: Color.Resolved) {
        self.init { traits in
            traits.colorScheme == .dark ? Color(dark) : Color(light)
        }
    }
}
