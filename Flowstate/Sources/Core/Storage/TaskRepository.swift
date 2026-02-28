import SwiftData
import Foundation

// MARK: - Task Repository Protocol
// All business logic goes through this protocol. Enables testing with mocks.
// @MainActor because SwiftData model objects are not Sendable and must stay
// on the actor that owns their ModelContext.

@MainActor
public protocol TaskRepositoryProtocol {
    // MARK: Tasks
    func createTask(_ task: FlowTask) throws
    func updateTask(_ task: FlowTask) throws
    func deleteTask(_ task: FlowTask) throws
    func completeTask(_ task: FlowTask) throws
    func uncompleteTask(_ task: FlowTask) throws

    func fetchInboxTasks() throws -> [FlowTask]
    func fetchTodayTasks() throws -> [FlowTask]
    func fetchOverdueTasks() throws -> [FlowTask]
    func fetchUpcomingTasks(days: Int) throws -> [FlowTask]
    func fetchTasksForProject(_ projectID: UUID) throws -> [FlowTask]
    func searchTasks(query: String) throws -> [FlowTask]

    // MARK: Projects
    func createProject(_ project: FlowProject) throws
    func fetchAllProjects() throws -> [FlowProject]
    func deleteProject(_ project: FlowProject) throws

    // MARK: Tags
    func createTag(_ tag: FlowTag) throws
    func fetchAllTags() throws -> [FlowTag]
    func findOrCreateTag(name: String) throws -> FlowTag
}

// MARK: - SwiftData Implementation

@MainActor
public final class SwiftDataTaskRepository: TaskRepositoryProtocol {
    private let modelContext: ModelContext

    public init(modelContainer: ModelContainer) {
        self.modelContext = modelContainer.mainContext
    }

    // MARK: - Task CRUD

    public func createTask(_ task: FlowTask) throws {
        modelContext.insert(task)
        try modelContext.save()
    }

    public func updateTask(_ task: FlowTask) throws {
        task.updatedAt = .now
        try modelContext.save()
    }

    public func deleteTask(_ task: FlowTask) throws {
        task.isArchived = true
        task.archivedAt = .now
        try modelContext.save()
    }

    public func completeTask(_ task: FlowTask) throws {
        task.isCompleted = true
        task.completedAt = .now
        task.updatedAt = .now
        try modelContext.save()
    }

    public func uncompleteTask(_ task: FlowTask) throws {
        task.isCompleted = false
        task.completedAt = nil
        task.updatedAt = .now
        try modelContext.save()
    }

    // MARK: - Task Queries

    public func fetchInboxTasks() throws -> [FlowTask] {
        let descriptor = FetchDescriptor<FlowTask>(
            predicate: #Predicate<FlowTask> { task in
                !task.isArchived && task.project == nil && !task.isCompleted
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func fetchTodayTasks() throws -> [FlowTask] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        let descriptor = FetchDescriptor<FlowTask>(
            predicate: #Predicate<FlowTask> { task in
                !task.isArchived && !task.isCompleted && (
                    (task.dueDate != nil && task.dueDate! >= startOfToday && task.dueDate! < endOfToday) ||
                    (task.scheduledDate != nil && task.scheduledDate! >= startOfToday && task.scheduledDate! < endOfToday)
                )
            },
            sortBy: [
                SortDescriptor(\.priorityRaw, order: .reverse),
                SortDescriptor(\.dueDate),
                SortDescriptor(\.order),
            ]
        )
        return try modelContext.fetch(descriptor)
    }

    public func fetchOverdueTasks() throws -> [FlowTask] {
        let startOfToday = Calendar.current.startOfDay(for: .now)

        let descriptor = FetchDescriptor<FlowTask>(
            predicate: #Predicate<FlowTask> { task in
                !task.isArchived && !task.isCompleted &&
                task.dueDate != nil && task.dueDate! < startOfToday
            },
            sortBy: [SortDescriptor(\.dueDate)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func fetchUpcomingTasks(days: Int) throws -> [FlowTask] {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: days, to: startOfToday)!

        let descriptor = FetchDescriptor<FlowTask>(
            predicate: #Predicate<FlowTask> { task in
                !task.isArchived && !task.isCompleted &&
                task.dueDate != nil && task.dueDate! >= startOfToday && task.dueDate! < endDate
            },
            sortBy: [SortDescriptor(\.dueDate), SortDescriptor(\.priorityRaw, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func fetchTasksForProject(_ projectID: UUID) throws -> [FlowTask] {
        let descriptor = FetchDescriptor<FlowTask>(
            predicate: #Predicate<FlowTask> { task in
                !task.isArchived && task.project?.id == projectID
            },
            sortBy: [SortDescriptor(\.order), SortDescriptor(\.createdAt)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func searchTasks(query: String) throws -> [FlowTask] {
        let descriptor = FetchDescriptor<FlowTask>(
            predicate: #Predicate<FlowTask> { task in
                !task.isArchived && (
                    task.title.localizedStandardContains(query) ||
                    task.notes.localizedStandardContains(query)
                )
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    // MARK: - Projects

    public func createProject(_ project: FlowProject) throws {
        modelContext.insert(project)
        try modelContext.save()
    }

    public func fetchAllProjects() throws -> [FlowProject] {
        let descriptor = FetchDescriptor<FlowProject>(
            predicate: #Predicate<FlowProject> { !$0.isArchived },
            sortBy: [SortDescriptor(\.order), SortDescriptor(\.createdAt)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func deleteProject(_ project: FlowProject) throws {
        project.isArchived = true
        project.archivedAt = .now
        try modelContext.save()
    }

    // MARK: - Tags

    public func createTag(_ tag: FlowTag) throws {
        modelContext.insert(tag)
        try modelContext.save()
    }

    public func fetchAllTags() throws -> [FlowTag] {
        let descriptor = FetchDescriptor<FlowTag>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func findOrCreateTag(name: String) throws -> FlowTag {
        let normalizedName = name.lowercased().trimmingCharacters(in: .whitespaces)
        let descriptor = FetchDescriptor<FlowTag>(
            predicate: #Predicate<FlowTag> { $0.name == normalizedName }
        )
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        let tag = FlowTag(name: normalizedName)
        modelContext.insert(tag)
        try modelContext.save()
        return tag
    }
}

// MARK: - Model Container Factory

public enum FlowModelContainer {
    public static func create(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([
            FlowTask.self,
            FlowProject.self,
            FlowSection.self,
            FlowTag.self,
            FocusSession.self,
            FlowHabit.self,
            HabitEntry.self,
        ])

        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory,
            cloudKitDatabase: inMemory ? .none : .automatic
        )

        return try ModelContainer(for: schema, configurations: [config])
    }
}
