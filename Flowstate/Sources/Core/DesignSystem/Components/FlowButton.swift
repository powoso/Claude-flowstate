import SwiftUI

// MARK: - Flowstate Button Styles
// Consistent button system with haptic feedback.

public enum FlowButtonStyle {
    case primary
    case secondary
    case ghost
    case destructive
}

public struct FlowButton: View {
    let title: String
    let icon: String?
    let style: FlowButtonStyle
    let isLoading: Bool
    let action: () -> Void

    public init(
        _ title: String,
        icon: String? = nil,
        style: FlowButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button {
            FlowHaptics.selection()
            action()
        } label: {
            HStack(spacing: FlowSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                        .scaleEffect(0.8)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                }

                Text(title)
                    .font(FlowTypography.bodyBold)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: style == .ghost ? nil : .infinity)
            .padding(.horizontal, FlowSpacing.lg)
            .padding(.vertical, FlowSpacing.sm)
            .background(backgroundColor, in: Capsule())
            .overlay {
                if style == .secondary {
                    Capsule().strokeBorder(FlowColors.separator, lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
        .accessibilityLabel(title)
    }

    private var foregroundColor: Color {
        switch style {
        case .primary: .white
        case .secondary: FlowColors.textPrimary
        case .ghost: FlowColors.accentFallback
        case .destructive: .white
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .primary: FlowColors.accentFallback
        case .secondary: FlowColors.secondaryBackground
        case .ghost: .clear
        case .destructive: FlowColors.destructive
        }
    }
}

// MARK: - Floating Action Button

public struct FlowFAB: View {
    let icon: String
    let action: () -> Void

    @State private var isPressed = false

    public init(icon: String = "plus", action: @escaping () -> Void) {
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button {
            FlowHaptics.selection()
            action()
        } label: {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(FlowColors.accentFallback, in: Circle())
                .shadow(color: FlowColors.accentFallback.opacity(0.3), radius: 8, y: 4)
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add new task")
        .sensoryFeedback(.impact(weight: .medium), trigger: isPressed)
    }
}

#Preview("Buttons") {
    VStack(spacing: 16) {
        FlowButton("Add Task", icon: "plus", style: .primary) {}
        FlowButton("Cancel", style: .secondary) {}
        FlowButton("Delete", icon: "trash", style: .destructive) {}
        FlowButton("See All", style: .ghost) {}
        FlowButton("Loading...", style: .primary, isLoading: true) {}

        Spacer()

        HStack {
            Spacer()
            FlowFAB {}
        }
    }
    .padding()
}
