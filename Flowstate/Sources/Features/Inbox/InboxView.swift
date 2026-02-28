import SwiftUI
import DesignSystem
import Storage

// MARK: - Inbox View
// Quick capture with natural language input + unsorted task list.
// Pull-down to create. Swipe to complete/delete. Skeleton loading.

public struct InboxView: View {
    @Bindable var viewModel: InboxViewModel
    @FocusState private var isInputFocused: Bool
    @State private var celebrationTaskID: String?

    public init(viewModel: InboxViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                mainContent
                inputBar
            }
            .navigationTitle("Inbox")
            .task { await viewModel.loadTasks() }
            .refreshable { await viewModel.loadTasks() }
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading {
            SkeletonTaskList(count: 6)
        } else if viewModel.tasks.isEmpty && viewModel.errorMessage == nil {
            EmptyStateView.inbox {
                isInputFocused = true
            }
        } else {
            taskList
        }
    }

    // MARK: - Task List

    private var taskList: some View {
        List {
            // Error banner
            if let error = viewModel.errorMessage {
                errorBanner(error)
            }

            ForEach(viewModel.tasks, id: \.id) { task in
                taskRow(for: task)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { await viewModel.deleteTask(task) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: true) {
                        Button {
                            Task { await viewModel.toggleComplete(task) }
                        } label: {
                            Label(
                                task.isCompleted ? "Undo" : "Complete",
                                systemImage: task.isCompleted ? "arrow.uturn.backward" : "checkmark"
                            )
                        }
                        .tint(FlowColors.success)
                    }
            }

            // Bottom spacer for input bar
            Color.clear.frame(height: 80)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.interactively)
    }

    private func taskRow(for task: FlowTask) -> some View {
        ZStack {
            TaskRow(
                data: TaskRowData(
                    id: task.id.uuidString,
                    title: task.title,
                    isCompleted: task.isCompleted,
                    priority: flowPriority(from: task.priority),
                    dueDate: task.dueDate,
                    tags: task.tags.map(\.name),
                    estimatedMinutes: task.estimatedMinutes
                ),
                onToggleComplete: {
                    Task { await viewModel.toggleComplete(task) }
                },
                onTap: {
                    // TODO: Navigate to task detail
                }
            )
            .listRowInsets(EdgeInsets())

            if celebrationTaskID == task.id.uuidString {
                CompletionCelebration(isShowing: Binding(
                    get: { celebrationTaskID == task.id.uuidString },
                    set: { if !$0 { celebrationTaskID = nil } }
                ))
            }
        }
    }

    // MARK: - NL Input Bar

    private var inputBar: some View {
        VStack(spacing: 0) {
            // Parse preview chips
            if !viewModel.inputText.isEmpty {
                parsePreview
            }

            HStack(spacing: FlowSpacing.xs) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(FlowColors.accentFallback)

                TextField("Add a task... \"Meeting tomorrow at 3pm #work !high\"",
                          text: $viewModel.inputText, axis: .vertical)
                    .font(FlowTypography.body)
                    .lineLimit(1...3)
                    .focused($isInputFocused)
                    .onSubmit { submitTask() }
                    .onChange(of: viewModel.inputText) { _, _ in
                        viewModel.updateParsedPreview()
                    }
                    .submitLabel(.done)

                if !viewModel.inputText.isEmpty {
                    Button {
                        submitTask()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(FlowColors.accentFallback)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, FlowSpacing.md)
            .padding(.vertical, FlowSpacing.sm)
            .background(.ultraThinMaterial)
        }
        .animation(FlowAnimation.quick, value: viewModel.inputText.isEmpty)
    }

    // MARK: - Parse Preview

    private var parsePreview: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: FlowSpacing.xs) {
                let preview = viewModel.parsedPreview

                if preview.combinedDateTime != nil || preview.date != nil {
                    previewChip(
                        icon: "calendar",
                        text: formatPreviewDate(preview.combinedDateTime ?? preview.date),
                        color: FlowColors.accentFallback
                    )
                }

                if preview.priority != .none {
                    previewChip(
                        icon: "exclamationmark",
                        text: priorityLabel(preview.priority),
                        color: priorityColor(preview.priority)
                    )
                }

                for tag in preview.tags {
                    previewChip(icon: "number", text: tag, color: FlowColors.success)
                }

                if let minutes = preview.estimatedMinutes {
                    previewChip(icon: "clock", text: formatMinutes(minutes), color: FlowColors.textSecondary)
                }

                if let location = preview.locationName {
                    previewChip(icon: "mappin", text: location, color: FlowColors.warning)
                }
            }
            .padding(.horizontal, FlowSpacing.md)
            .padding(.vertical, FlowSpacing.xs)
        }
        .background(.ultraThinMaterial)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func previewChip(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: FlowSpacing.xxxs) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .bold))
            Text(text)
                .font(FlowTypography.caption)
        }
        .foregroundStyle(color)
        .padding(.horizontal, FlowSpacing.xs)
        .padding(.vertical, FlowSpacing.xxs)
        .background(color.opacity(0.12), in: Capsule())
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: FlowSpacing.xs) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(FlowColors.warning)
            Text(message)
                .font(FlowTypography.subheadline)
                .foregroundStyle(FlowColors.textSecondary)
            Spacer()
            Button("Retry") {
                Task { await viewModel.loadTasks() }
            }
            .font(FlowTypography.bodyBold)
            .foregroundStyle(FlowColors.accentFallback)
        }
        .padding(FlowSpacing.sm)
        .background(FlowColors.warning.opacity(0.1), in: RoundedRectangle(cornerRadius: FlowRadius.sm))
        .listRowSeparator(.hidden)
    }

    // MARK: - Helpers

    private func submitTask() {
        Task {
            await viewModel.createTaskFromInput()
            FlowHaptics.success()
        }
    }

    private func flowPriority(from taskPriority: TaskPriority) -> FlowPriority {
        FlowPriority(rawValue: taskPriority.rawValue) ?? .none
    }

    private func formatPreviewDate(_ date: Date?) -> String {
        guard let date else { return "" }
        let calendar = Calendar.current
        let formatter = DateFormatter()

        if calendar.isDateInToday(date) {
            formatter.dateFormat = "'Today' h:mm a"
        } else if calendar.isDateInTomorrow(date) {
            formatter.dateFormat = "'Tomorrow' h:mm a"
        } else {
            formatter.dateFormat = "EEE, MMM d h:mm a"
        }
        return formatter.string(from: date)
    }

    private func priorityLabel(_ priority: NLParser.ParsedPriority) -> String {
        switch priority {
        case .urgent: "Urgent"
        case .high: "High"
        case .medium: "Medium"
        case .low: "Low"
        case .none: ""
        }
    }

    private func priorityColor(_ priority: NLParser.ParsedPriority) -> Color {
        switch priority {
        case .urgent: FlowColors.priorityUrgent
        case .high: FlowColors.priorityHigh
        case .medium: FlowColors.priorityMedium
        case .low: FlowColors.priorityLow
        case .none: FlowColors.textTertiary
        }
    }

    private func formatMinutes(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes)m" }
        let h = minutes / 60
        let m = minutes % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }
}
