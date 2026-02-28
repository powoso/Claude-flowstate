import SwiftUI

// MARK: - Task Row
// The core list cell used everywhere tasks appear.
// Supports swipe actions, priority indicators, metadata chips, and accessibility.

public struct TaskRowData: Sendable {
    public let id: String
    public var title: String
    public var isCompleted: Bool
    public var priority: FlowPriority
    public var dueDate: Date?
    public var projectName: String?
    public var projectColor: Color?
    public var tags: [String]
    public var estimatedMinutes: Int?
    public var notes: String?

    public init(
        id: String,
        title: String,
        isCompleted: Bool = false,
        priority: FlowPriority = .none,
        dueDate: Date? = nil,
        projectName: String? = nil,
        projectColor: Color? = nil,
        tags: [String] = [],
        estimatedMinutes: Int? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.priority = priority
        self.dueDate = dueDate
        self.projectName = projectName
        self.projectColor = projectColor
        self.tags = tags
        self.estimatedMinutes = estimatedMinutes
        self.notes = notes
    }
}

public struct TaskRow: View {
    let data: TaskRowData
    var onToggleComplete: () -> Void
    var onTap: () -> Void

    @State private var isCompleted: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        data: TaskRowData,
        onToggleComplete: @escaping () -> Void = {},
        onTap: @escaping () -> Void = {}
    ) {
        self.data = data
        self._isCompleted = State(initialValue: data.isCompleted)
        self.onToggleComplete = onToggleComplete
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: FlowSpacing.xs) {
                FlowCheckbox(
                    isChecked: $isCompleted,
                    priority: data.priority
                ) {
                    onToggleComplete()
                }

                VStack(alignment: .leading, spacing: FlowSpacing.xxs) {
                    // Title
                    Text(data.title)
                        .font(FlowTypography.body)
                        .foregroundStyle(isCompleted ? FlowColors.textTertiary : FlowColors.textPrimary)
                        .strikethrough(isCompleted)
                        .lineLimit(2)
                        .animation(FlowAnimation.fadeIn, value: isCompleted)

                    // Metadata row
                    if hasMetadata {
                        metadataRow
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, FlowSpacing.xs)
            .padding(.horizontal, FlowSpacing.md)
            .frame(minHeight: FlowSize.taskRowMinHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityHint("Double tap to view details")
    }

    // MARK: - Metadata

    private var hasMetadata: Bool {
        data.dueDate != nil || data.projectName != nil || !data.tags.isEmpty || data.estimatedMinutes != nil
    }

    private var metadataRow: some View {
        HStack(spacing: FlowSpacing.xs) {
            if let dueDate = data.dueDate {
                dueDateChip(dueDate)
            }

            if let project = data.projectName {
                projectChip(project)
            }

            if let minutes = data.estimatedMinutes {
                timeChip(minutes)
            }

            ForEach(data.tags.prefix(2), id: \.self) { tag in
                TagChip(label: tag, style: .compact)
            }
        }
    }

    private func dueDateChip(_ date: Date) -> some View {
        HStack(spacing: FlowSpacing.xxxs) {
            Image(systemName: dueDateIcon(date))
                .font(.system(size: 10))
            Text(formattedDueDate(date))
                .font(FlowTypography.caption)
        }
        .foregroundStyle(dueDateColor(date))
    }

    private func projectChip(_ name: String) -> some View {
        HStack(spacing: FlowSpacing.xxxs) {
            Circle()
                .fill(data.projectColor ?? FlowColors.accentFallback)
                .frame(width: 6, height: 6)
            Text(name)
                .font(FlowTypography.caption)
                .foregroundStyle(FlowColors.textSecondary)
        }
    }

    private func timeChip(_ minutes: Int) -> some View {
        HStack(spacing: FlowSpacing.xxxs) {
            Image(systemName: "clock")
                .font(.system(size: 10))
            Text(formatDuration(minutes))
                .font(FlowTypography.monoCaption)
        }
        .foregroundStyle(FlowColors.textTertiary)
    }

    // MARK: - Date Formatting

    private func formattedDueDate(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInTomorrow(date) { return "Tomorrow" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }

        let formatter = DateFormatter()
        let daysDiff = calendar.dateComponents([.day], from: calendar.startOfDay(for: .now), to: calendar.startOfDay(for: date)).day ?? 0

        if daysDiff > 0 && daysDiff <= 7 {
            formatter.dateFormat = "EEEE" // "Monday"
        } else {
            formatter.dateFormat = "MMM d"  // "Jan 15"
        }
        return formatter.string(from: date)
    }

    private func dueDateIcon(_ date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "calendar.circle.fill" }
        if date < .now { return "exclamationmark.circle.fill" }
        return "calendar"
    }

    private func dueDateColor(_ date: Date) -> Color {
        let calendar = Calendar.current
        if date < calendar.startOfDay(for: .now) { return FlowColors.destructive }
        if calendar.isDateInToday(date) { return FlowColors.accentFallback }
        return FlowColors.textSecondary
    }

    private func formatDuration(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes)m" }
        let h = minutes / 60
        let m = minutes % 60
        return m > 0 ? "\(h)h\(m)m" : "\(h)h"
    }

    // MARK: - Accessibility

    private var accessibilityLabel: String {
        var parts = [data.title]
        if isCompleted { parts.append("completed") }
        if data.priority != .none { parts.append("\(data.priority.label) priority") }
        if let date = data.dueDate { parts.append("due \(formattedDueDate(date))") }
        if let project = data.projectName { parts.append("in \(project)") }
        return parts.joined(separator: ", ")
    }
}

#Preview("Task Rows") {
    List {
        TaskRow(data: .init(
            id: "1", title: "Design the onboarding flow",
            priority: .high, dueDate: .now,
            projectName: "Flowstate", tags: ["design"]
        ))
        TaskRow(data: .init(
            id: "2", title: "Buy groceries",
            priority: .low, dueDate: .now.addingTimeInterval(86400),
            estimatedMinutes: 30
        ))
        TaskRow(data: .init(
            id: "3", title: "Completed task example",
            isCompleted: true, priority: .medium
        ))
        TaskRow(data: .init(
            id: "4", title: "Overdue task that needs attention right away",
            priority: .urgent,
            dueDate: .now.addingTimeInterval(-86400),
            projectName: "Work", tags: ["urgent", "client"]
        ))
    }
    .listStyle(.plain)
}
