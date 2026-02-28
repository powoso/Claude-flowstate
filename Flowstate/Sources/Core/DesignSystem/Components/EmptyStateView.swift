import SwiftUI

// MARK: - Empty State View
// Illustrated, encouraging, actionable empty states.
// Never show a blank screen — always guide the user forward.

public struct EmptyStateView: View {
    let symbol: String
    let title: String
    let message: String
    var actionTitle: String?
    var action: (() -> Void)?

    public init(
        symbol: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.symbol = symbol
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: FlowSpacing.lg) {
            Spacer()

            Image(systemName: symbol)
                .font(.system(size: 48))
                .foregroundStyle(FlowColors.accentFallback.opacity(0.6))
                .symbolEffect(.pulse.byLayer, options: .repeating)
                .accessibilityHidden(true)

            VStack(spacing: FlowSpacing.xs) {
                Text(title)
                    .font(FlowTypography.title3)
                    .foregroundStyle(FlowColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .font(FlowTypography.subheadline)
                    .foregroundStyle(FlowColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 280)
            }

            if let actionTitle, let action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(FlowTypography.bodyBold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, FlowSpacing.xl)
                        .padding(.vertical, FlowSpacing.sm)
                        .background(FlowColors.accentFallback, in: Capsule())
                }
                .buttonStyle(.plain)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, FlowSpacing.xxl)
    }
}

// MARK: - Preset Empty States

public extension EmptyStateView {
    static func inbox(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            symbol: "tray",
            title: "Inbox Zero",
            message: "Your inbox is clear. Nice work! Capture a new task whenever inspiration strikes.",
            actionTitle: "Add Task",
            action: action
        )
    }

    static func today() -> EmptyStateView {
        EmptyStateView(
            symbol: "sun.max",
            title: "Nothing planned for today",
            message: "Drag tasks here from your inbox or projects, or just enjoy your free day."
        )
    }

    static func search() -> EmptyStateView {
        EmptyStateView(
            symbol: "magnifyingglass",
            title: "No results",
            message: "Try different keywords or check your filters."
        )
    }

    static func project() -> EmptyStateView {
        EmptyStateView(
            symbol: "folder",
            title: "No tasks yet",
            message: "Add your first task to get this project started."
        )
    }
}

#Preview("Empty States") {
    TabView {
        EmptyStateView.inbox {}
            .tabItem { Label("Inbox", systemImage: "tray") }

        EmptyStateView.today()
            .tabItem { Label("Today", systemImage: "sun.max") }

        EmptyStateView.search()
            .tabItem { Label("Search", systemImage: "magnifyingglass") }
    }
}
