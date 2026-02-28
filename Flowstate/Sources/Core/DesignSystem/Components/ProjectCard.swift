import SwiftUI

// MARK: - Project Card
// Used in project list and project picker.

public struct ProjectCardData: Sendable {
    public let id: String
    public let name: String
    public let color: Color
    public let taskCount: Int
    public let completedCount: Int
    public let icon: String

    public init(
        id: String,
        name: String,
        color: Color = FlowColors.accentFallback,
        taskCount: Int = 0,
        completedCount: Int = 0,
        icon: String = "folder.fill"
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.taskCount = taskCount
        self.completedCount = completedCount
        self.icon = icon
    }

    public var progress: Double {
        guard taskCount > 0 else { return 0 }
        return Double(completedCount) / Double(taskCount)
    }

    public var remainingCount: Int {
        taskCount - completedCount
    }
}

public struct ProjectCard: View {
    let data: ProjectCardData
    var onTap: () -> Void

    public init(data: ProjectCardData, onTap: @escaping () -> Void = {}) {
        self.data = data
        self.onTap = onTap
    }

    public var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: FlowSpacing.sm) {
                HStack {
                    Image(systemName: data.icon)
                        .font(.system(size: 18))
                        .foregroundStyle(data.color)
                        .frame(width: FlowSize.avatar, height: FlowSize.avatar)
                        .background(data.color.opacity(0.12), in: RoundedRectangle(cornerRadius: FlowRadius.sm))

                    Spacer()

                    if data.taskCount > 0 {
                        Text("\(data.remainingCount)")
                            .font(FlowTypography.badge)
                            .foregroundStyle(FlowColors.textSecondary)
                            .padding(.horizontal, FlowSpacing.xs)
                            .padding(.vertical, FlowSpacing.xxxs)
                            .background(FlowColors.tertiaryBackground, in: Capsule())
                    }
                }

                VStack(alignment: .leading, spacing: FlowSpacing.xxs) {
                    Text(data.name)
                        .font(FlowTypography.bodyBold)
                        .foregroundStyle(FlowColors.textPrimary)
                        .lineLimit(1)

                    if data.taskCount > 0 {
                        Text("\(data.remainingCount) remaining")
                            .font(FlowTypography.caption)
                            .foregroundStyle(FlowColors.textSecondary)
                    }
                }

                if data.taskCount > 0 {
                    ProgressView(value: data.progress)
                        .tint(data.color)
                }
            }
            .padding(FlowSpacing.md)
            .background(FlowColors.secondaryBackground, in: RoundedRectangle(cornerRadius: FlowRadius.md))
            .contentShape(RoundedRectangle(cornerRadius: FlowRadius.md))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(data.name) project, \(data.remainingCount) tasks remaining")
    }
}

#Preview("Project Cards") {
    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
        ProjectCard(data: .init(id: "1", name: "Flowstate App", color: .indigo, taskCount: 24, completedCount: 18, icon: "app.fill"))
        ProjectCard(data: .init(id: "2", name: "Marketing", color: .orange, taskCount: 8, completedCount: 2, icon: "megaphone.fill"))
        ProjectCard(data: .init(id: "3", name: "Personal", color: .green, taskCount: 0, icon: "person.fill"))
        ProjectCard(data: .init(id: "4", name: "Research", color: .purple, taskCount: 12, completedCount: 12, icon: "book.fill"))
    }
    .padding()
}
