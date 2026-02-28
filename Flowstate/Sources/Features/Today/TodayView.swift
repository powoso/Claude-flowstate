import SwiftUI
import DesignSystem
import Storage

// MARK: - Today View
// Morning briefing: greeting, stats bar, overdue section, today's tasks.
// Feels like opening a personal daily planner.

public struct TodayView: View {
    @Bindable var viewModel: TodayViewModel
    @State private var showGreeting = false

    public init(viewModel: TodayViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: FlowSpacing.lg) {
                    if viewModel.isLoading {
                        loadingState
                    } else if viewModel.errorMessage != nil {
                        errorState
                    } else {
                        greetingHeader
                        statsBar
                        overdueSection
                        todaySection
                        completedSection
                        emptyTodayState
                    }
                }
                .padding(.horizontal, FlowSpacing.md)
                .padding(.top, FlowSpacing.sm)
            }
            .navigationTitle("Today")
            .task {
                await viewModel.loadToday()
                withAnimation(FlowAnimation.gentle.delay(0.2)) {
                    showGreeting = true
                }
            }
            .refreshable { await viewModel.loadToday() }
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: FlowSpacing.xxs) {
            Text(viewModel.greeting)
                .font(FlowTypography.title)
                .foregroundStyle(FlowColors.textPrimary)

            Text(formattedDate)
                .font(FlowTypography.subheadline)
                .foregroundStyle(FlowColors.textSecondary)

            Text(viewModel.briefingSummary)
                .font(FlowTypography.subheadline)
                .foregroundStyle(FlowColors.accentFallback)
                .padding(.top, FlowSpacing.xxxs)
        }
        .padding(.vertical, FlowSpacing.sm)
        .opacity(showGreeting ? 1 : 0)
        .offset(y: showGreeting ? 0 : 10)
    }

    // MARK: - Stats Bar

    @ViewBuilder
    private var statsBar: some View {
        if viewModel.totalTasksToday > 0 || viewModel.completedCountToday > 0 {
            HStack(spacing: FlowSpacing.md) {
                statItem(
                    value: "\(viewModel.overdueTasks.count)",
                    label: "Overdue",
                    color: viewModel.overdueTasks.isEmpty ? FlowColors.textTertiary : FlowColors.destructive
                )
                statItem(
                    value: "\(viewModel.todayTasks.filter { !$0.isCompleted }.count)",
                    label: "To Do",
                    color: FlowColors.accentFallback
                )
                statItem(
                    value: "\(viewModel.completedCountToday)",
                    label: "Done",
                    color: FlowColors.success
                )
            }
            .padding(FlowSpacing.md)
            .background(FlowColors.secondaryBackground, in: RoundedRectangle(cornerRadius: FlowRadius.md))
        }
    }

    private func statItem(value: String, label: String, color: Color) -> some View {
        VStack(spacing: FlowSpacing.xxs) {
            Text(value)
                .font(FlowTypography.statNumber)
                .foregroundStyle(color)
            Text(label)
                .font(FlowTypography.caption)
                .foregroundStyle(FlowColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Overdue Section

    @ViewBuilder
    private var overdueSection: some View {
        if !viewModel.overdueTasks.isEmpty {
            section(title: "Overdue", icon: "exclamationmark.circle.fill", color: FlowColors.destructive) {
                ForEach(viewModel.overdueTasks, id: \.id) { task in
                    taskCard(task)
                }
            }
        }
    }

    // MARK: - Today Section

    @ViewBuilder
    private var todaySection: some View {
        let remaining = viewModel.todayTasks.filter { !$0.isCompleted }
        if !remaining.isEmpty {
            section(title: "Today", icon: "sun.max.fill", color: FlowColors.accentFallback) {
                ForEach(remaining, id: \.id) { task in
                    taskCard(task)
                }
            }
        }
    }

    // MARK: - Completed Section

    @ViewBuilder
    private var completedSection: some View {
        if !viewModel.completedToday.isEmpty {
            DisclosureGroup {
                ForEach(viewModel.completedToday, id: \.id) { task in
                    taskCard(task)
                }
            } label: {
                HStack(spacing: FlowSpacing.xs) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(FlowColors.success)
                    Text("Completed (\(viewModel.completedToday.count))")
                        .font(FlowTypography.bodyBold)
                        .foregroundStyle(FlowColors.textSecondary)
                }
            }
        }
    }

    // MARK: - Empty State

    @ViewBuilder
    private var emptyTodayState: some View {
        if viewModel.overdueTasks.isEmpty && viewModel.todayTasks.isEmpty && viewModel.completedToday.isEmpty {
            EmptyStateView.today()
                .frame(maxWidth: .infinity, minHeight: 300)
        }
    }

    // MARK: - Loading & Error

    private var loadingState: some View {
        VStack(spacing: FlowSpacing.xl) {
            SkeletonShape(width: 180, height: 28)
            SkeletonShape(width: 120, height: 14)
            SkeletonTaskList(count: 4)
        }
        .padding(.top, FlowSpacing.xl)
    }

    @ViewBuilder
    private var errorState: some View {
        if let error = viewModel.errorMessage {
            VStack(spacing: FlowSpacing.md) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 40))
                    .foregroundStyle(FlowColors.warning)

                Text(error)
                    .font(FlowTypography.subheadline)
                    .foregroundStyle(FlowColors.textSecondary)
                    .multilineTextAlignment(.center)

                FlowButton("Try Again", icon: "arrow.clockwise", style: .secondary) {
                    Task { await viewModel.loadToday() }
                }
            }
            .frame(maxWidth: .infinity, minHeight: 300)
        }
    }

    // MARK: - Shared Components

    private func section<Content: View>(
        title: String,
        icon: String,
        color: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: FlowSpacing.sm) {
            HStack(spacing: FlowSpacing.xs) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(FlowTypography.bodyBold)
                    .foregroundStyle(FlowColors.textPrimary)
            }

            content()
        }
    }

    private func taskCard(_ task: FlowTask) -> some View {
        TaskRow(
            data: TaskRowData(
                id: task.id.uuidString,
                title: task.title,
                isCompleted: task.isCompleted,
                priority: FlowPriority(rawValue: task.priority.rawValue) ?? .none,
                dueDate: task.dueDate,
                projectName: task.project?.name,
                tags: task.tags.map(\.name),
                estimatedMinutes: task.estimatedMinutes
            ),
            onToggleComplete: {
                Task { await viewModel.toggleComplete(task) }
            }
        )
        .background(FlowColors.secondaryBackground, in: RoundedRectangle(cornerRadius: FlowRadius.sm))
    }

    // MARK: - Helpers

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: .now)
    }
}
