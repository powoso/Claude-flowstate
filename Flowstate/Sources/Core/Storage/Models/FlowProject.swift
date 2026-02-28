import SwiftData
import Foundation

// MARK: - FlowProject Model
// Organizes tasks into projects with sections, color, and icon.

@Model
public final class FlowProject: @unchecked Sendable {
    #Unique<FlowProject>([\.id])

    public var id: UUID
    public var createdAt: Date
    public var updatedAt: Date

    public var name: String
    public var notes: String
    public var colorIndex: Int
    public var icon: String
    public var order: Int

    public var isArchived: Bool
    public var archivedAt: Date?

    // MARK: - Relationships

    public var tasks: [FlowTask]

    @Relationship(deleteRule: .cascade, inverse: \FlowSection.project)
    public var sections: [FlowSection]

    // MARK: - Computed

    public var activeTasks: [FlowTask] {
        tasks.filter { !$0.isArchived }
    }

    public var completedCount: Int {
        activeTasks.filter(\.isCompleted).count
    }

    public var remainingCount: Int {
        activeTasks.filter { !$0.isCompleted }.count
    }

    public var progress: Double {
        let active = activeTasks
        guard !active.isEmpty else { return 0 }
        return Double(completedCount) / Double(active.count)
    }

    // MARK: - Init

    public init(
        name: String,
        notes: String = "",
        colorIndex: Int = 0,
        icon: String = "folder.fill"
    ) {
        self.id = UUID()
        self.createdAt = .now
        self.updatedAt = .now
        self.name = name
        self.notes = notes
        self.colorIndex = colorIndex
        self.icon = icon
        self.order = 0
        self.isArchived = false
        self.archivedAt = nil
        self.tasks = []
        self.sections = []
    }
}

// MARK: - FlowSection (sub-grouping within a project)

@Model
public final class FlowSection: @unchecked Sendable {
    #Unique<FlowSection>([\.id])

    public var id: UUID
    public var name: String
    public var order: Int

    public var project: FlowProject?

    public init(name: String, order: Int = 0) {
        self.id = UUID()
        self.name = name
        self.order = order
    }
}
