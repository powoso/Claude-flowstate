import SwiftData
import Foundation

// MARK: - FlowTask Model
// Core task entity. Supports projects, tags, recurrence, time estimates, and focus sessions.

@Model
public final class FlowTask: @unchecked Sendable {
    // MARK: - Identity
    #Unique<FlowTask>([\.id])

    public var id: UUID
    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Content
    public var title: String
    public var notes: String
    public var isCompleted: Bool
    public var completedAt: Date?

    // MARK: - Organization
    public var priorityRaw: Int
    public var dueDate: Date?
    public var scheduledDate: Date?
    public var estimatedMinutes: Int?
    public var order: Int

    // MARK: - Relationships
    @Relationship(deleteRule: .nullify, inverse: \FlowProject.tasks)
    public var project: FlowProject?

    @Relationship(deleteRule: .nullify, inverse: \FlowTag.tasks)
    public var tags: [FlowTag]

    // MARK: - Recurrence
    public var recurrenceRule: String?

    // MARK: - Focus tracking
    public var totalFocusSeconds: Int

    // MARK: - Location
    public var locationName: String?

    // MARK: - Soft delete
    public var isArchived: Bool
    public var archivedAt: Date?

    // MARK: - Computed

    public var priority: TaskPriority {
        get { TaskPriority(rawValue: priorityRaw) ?? .none }
        set { priorityRaw = newValue.rawValue }
    }

    public var isOverdue: Bool {
        guard let dueDate, !isCompleted else { return false }
        return dueDate < Calendar.current.startOfDay(for: .now)
    }

    public var isDueToday: Bool {
        guard let dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }

    public var isScheduledToday: Bool {
        guard let scheduledDate else { return false }
        return Calendar.current.isDateInToday(scheduledDate)
    }

    // MARK: - Init

    public init(
        title: String,
        notes: String = "",
        priority: TaskPriority = .none,
        dueDate: Date? = nil,
        scheduledDate: Date? = nil,
        estimatedMinutes: Int? = nil,
        project: FlowProject? = nil,
        tags: [FlowTag] = [],
        recurrenceRule: String? = nil,
        locationName: String? = nil
    ) {
        self.id = UUID()
        self.createdAt = .now
        self.updatedAt = .now
        self.title = title
        self.notes = notes
        self.isCompleted = false
        self.completedAt = nil
        self.priorityRaw = priority.rawValue
        self.dueDate = dueDate
        self.scheduledDate = scheduledDate
        self.estimatedMinutes = estimatedMinutes
        self.order = 0
        self.project = project
        self.tags = tags
        self.recurrenceRule = recurrenceRule
        self.totalFocusSeconds = 0
        self.locationName = locationName
        self.isArchived = false
        self.archivedAt = nil
    }
}

// MARK: - Task Priority

public enum TaskPriority: Int, Codable, CaseIterable, Sendable {
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
}
