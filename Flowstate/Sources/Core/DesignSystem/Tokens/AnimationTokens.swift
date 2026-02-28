import SwiftUI

// MARK: - Flowstate Animation System
// Spring-first. Every animation respects Reduce Motion.

public enum FlowAnimation {

    // MARK: - Springs

    /// Standard interaction spring (e.g., button press, toggle).
    public static let standard = Animation.spring(response: 0.5, dampingFraction: 0.8)

    /// Snappy spring for small UI feedback (e.g., checkbox, chip tap).
    public static let snappy = Animation.spring(response: 0.35, dampingFraction: 0.75)

    /// Bouncy spring for celebratory moments (e.g., task complete).
    public static let bouncy = Animation.spring(response: 0.5, dampingFraction: 0.6)

    /// Gentle spring for large transitions (e.g., sheet presentation).
    public static let gentle = Animation.spring(response: 0.6, dampingFraction: 0.85)

    /// Quick spring for micro-interactions (e.g., swipe snap-back).
    public static let quick = Animation.spring(response: 0.25, dampingFraction: 0.8)

    // MARK: - Easing

    /// Smooth ease-out for fades and opacity changes.
    public static let fadeIn = Animation.easeOut(duration: 0.2)

    /// Standard ease-in-out.
    public static let smooth = Animation.easeInOut(duration: 0.3)

    // MARK: - Stagger

    /// Delay for staggered list animations.
    public static func stagger(index: Int, base: Double = 0.03) -> Animation {
        standard.delay(Double(index) * base)
    }
}

// MARK: - Reduce Motion Support

public struct FlowAnimationModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation

    public func body(content: Content) -> some View {
        content.animation(reduceMotion ? .default : animation, value: true)
    }
}

/// Conditionally applies spring or crossfade based on Reduce Motion.
public struct ReduceMotionTransaction: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public func body(content: Content) -> some View {
        content.transaction { transaction in
            if reduceMotion {
                transaction.animation = .default
            }
        }
    }
}

public extension View {
    func flowAnimation(_ animation: Animation = FlowAnimation.standard) -> some View {
        modifier(FlowAnimationModifier(animation: animation))
    }

    func respectReduceMotion() -> some View {
        modifier(ReduceMotionTransaction())
    }
}
