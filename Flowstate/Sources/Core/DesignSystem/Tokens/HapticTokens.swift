#if canImport(UIKit)
import UIKit

// MARK: - Flowstate Haptic System
// Consistent haptic language across the app.

public enum FlowHaptics {

    /// Light tap — selection changes, minor interactions.
    public static func selection() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    /// Medium tap — task completion, meaningful state change.
    public static func taskComplete() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    /// Rigid tap — drag-and-drop snap, reorder.
    public static func snap() {
        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
    }

    /// Success — streak milestone, focus session complete.
    public static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    /// Warning — approaching deadline, overdue.
    public static func warning() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }

    /// Error — failed action, validation error.
    public static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

#else

// macOS stub — haptics are iOS-only.
public enum FlowHaptics {
    public static func selection() {}
    public static func taskComplete() {}
    public static func snap() {}
    public static func success() {}
    public static func warning() {}
    public static func error() {}
}

#endif
