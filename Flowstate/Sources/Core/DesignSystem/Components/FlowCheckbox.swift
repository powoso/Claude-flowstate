import SwiftUI

// MARK: - Animated Checkbox
// Satisfying completion animation with haptic feedback.
// Supports priority-colored rings and accessible labeling.

public struct FlowCheckbox: View {
    @Binding var isChecked: Bool
    let priority: FlowPriority
    var onToggle: (() -> Void)?

    @State private var animationScale: CGFloat = 1.0
    @State private var checkmarkTrim: CGFloat = 0.0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        isChecked: Binding<Bool>,
        priority: FlowPriority = .none,
        onToggle: (() -> Void)? = nil
    ) {
        self._isChecked = isChecked
        self.priority = priority
        self.onToggle = onToggle
    }

    public var body: some View {
        Button {
            toggle()
        } label: {
            ZStack {
                // Outer ring
                Circle()
                    .strokeBorder(ringColor, lineWidth: isChecked ? 0 : 2)
                    .frame(width: FlowSize.checkbox, height: FlowSize.checkbox)

                // Filled background on completion
                Circle()
                    .fill(ringColor)
                    .frame(width: FlowSize.checkbox, height: FlowSize.checkbox)
                    .scaleEffect(isChecked ? 1.0 : 0.0)

                // Checkmark
                if isChecked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .scaleEffect(animationScale)
        }
        .buttonStyle(.plain)
        .frame(width: FlowSize.touchTarget, height: FlowSize.touchTarget)
        .accessibilityLabel(isChecked ? "Completed" : "Not completed")
        .accessibilityHint("Double tap to \(isChecked ? "uncomplete" : "complete") this task")
        .accessibilityAddTraits(isChecked ? .isSelected : [])
    }

    private var ringColor: Color {
        switch priority {
        case .urgent: FlowColors.priorityUrgent
        case .high: FlowColors.priorityHigh
        case .medium: FlowColors.priorityMedium
        case .low: FlowColors.priorityLow
        case .none: FlowColors.textTertiary
        }
    }

    private func toggle() {
        let newValue = !isChecked

        if reduceMotion {
            isChecked = newValue
            if newValue { FlowHaptics.taskComplete() }
            onToggle?()
            return
        }

        withAnimation(FlowAnimation.snappy) {
            isChecked = newValue
        }

        if newValue {
            FlowHaptics.taskComplete()

            // Bounce effect
            withAnimation(FlowAnimation.bouncy) {
                animationScale = 1.2
            }
            withAnimation(FlowAnimation.bouncy.delay(0.15)) {
                animationScale = 1.0
            }
        }

        onToggle?()
    }
}

// MARK: - Priority Enum (shared across design system)

public enum FlowPriority: Int, Codable, CaseIterable, Sendable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    case urgent = 4

    public var label: String {
        switch self {
        case .none: "None"
        case .low: "Low"
        case .medium: "Medium"
        case .high: "High"
        case .urgent: "Urgent"
        }
    }

    public var color: Color {
        switch self {
        case .urgent: FlowColors.priorityUrgent
        case .high: FlowColors.priorityHigh
        case .medium: FlowColors.priorityMedium
        case .low: FlowColors.priorityLow
        case .none: FlowColors.textTertiary
        }
    }

    public var symbolName: String {
        switch self {
        case .urgent: "exclamationmark.3"
        case .high: "exclamationmark.2"
        case .medium: "exclamationmark"
        case .low: "arrow.down"
        case .none: "minus"
        }
    }
}

#Preview("Checkbox States") {
    VStack(spacing: 20) {
        ForEach(FlowPriority.allCases, id: \.rawValue) { priority in
            HStack {
                FlowCheckbox(isChecked: .constant(false), priority: priority)
                FlowCheckbox(isChecked: .constant(true), priority: priority)
                Text(priority.label)
                    .font(FlowTypography.body)
            }
        }
    }
    .padding()
}
