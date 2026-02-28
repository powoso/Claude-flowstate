import SwiftData
import Foundation

// MARK: - Task Repository Protocol
// All business logic goes through this protocol. Enables testing with mocks.

public protocol TaskRepositoryProtocol: Sendable {
    // MARK: Tasks
    func createTask(_ task: FlowTask) async throws
    func updateTask(_ task: FlowTask) async throws
    func deleteTask(_ task: FlowTask) async throws
    func completeTask(_ task: FlowTask) async throws
    func uncompleteTask(_ task: FlowTask) async throws

    func fetchInboxTasks() async throws -> [FlowTask]
    func fetchTodayTasks() async throws -> [FlowTask]
    func fetchOverdueTasks() async throws -> [FlowTask]
    func fetchUpcomingTasks(days: Int) async throws -> [FlowTask]
    func fetchTasksForProject(_ projectID: UUID) async throws -> [FlowTask]
    func searchTasks(query: String) async throws -> [FlowTask]

    // MARK: Projects
    func createProject(_ project: FlowProject) async throws
    func fetchAllProjects() async throws -> [FlowProject]
    func deleteProject(_ project: FlowProject) async throws

    // MARK: Tags
    func createTag(_ tag: FlowTag) async throws
    func fetchAllTags() async throws -> [FlowTag]
    func findOrCreateTag(name: String) async throws -> FlowTag
}

// MARK: - SwiftData Implementation

@ModelActor
public actor SwiftDataTaskRepository: TaskRepositoryProtocol {

    // MARK: - Task CRUD

    public func createTask(_ task: FlowTask) async throws {
        modelContext.insert(task)
        try modelContext.save()
    }

    public func updateTask(_ task: FlowTask) async throws {
        task.updatedAt = .now
        try modelContext.save()
    }

    public func deleteTask(_ task: FlowTask) async throws {
        task.isArchived = true
        task.archivedAt = .now
        try modelContext.save()
    }

    public func completeTask(_ task: FlowTask) async throws {
        task.isCompleted = true
        task.completedAt = .now
        task.updatedAt = .now
        try modelContext.save()
    }

    public func uncompleteTask(_ task: FlowTask) async throws {
        task.isCompleted = false
        task.completedAt = nil
        task.updatedAt = .now
        try modelContext.save()
    }

    // MARK: - Task Queries

    public func fetchInboxTasks() async throws -> [FlowTask] {
        let descriptor = FetchDescriptor<FlowTask>(
            predicate: #Predicate<FlowTask> { task in
                !task.isArchived && task.project == nil && !task.isCompleted
            },
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func fetchTodayTasks() async throws -> [FlowTask] {
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

    public func fetchOverdueTasks() async throws -> [FlowTask] {
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

    public func fetchUpcomingTasks(days: Int) async throws -> [FlowTask] {
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

    public func fetchTasksForProject(_ projectID: UUID) async throws -> [FlowTask] {
        let descriptor = FetchDescriptor<FlowTask>(
            predicate: #Predicate<FlowTask> { task in
                !task.isArchived && task.project?.id == projectID
            },
            sortBy: [SortDescriptor(\.order), SortDescriptor(\.createdAt)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func searchTasks(query: String) async throws -> [FlowTask] {
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

    public func createProject(_ project: FlowProject) async throws {
        modelContext.insert(project)
        try modelContext.save()
    }

    public func fetchAllProjects() async throws -> [FlowProject] {
        let descriptor = FetchDescriptor<FlowProject>(
            predicate: #Predicate<FlowProject> { !$0.isArchived },
            sortBy: [SortDescriptor(\.order), SortDescriptor(\.createdAt)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func deleteProject(_ project: FlowProject) async throws {
        project.isArchived = true
        project.archivedAt = .now
        try modelContext.save()
    }

    // MARK: - Tags

    public func createTag(_ tag: FlowTag) async throws {
        modelContext.insert(tag)
        try modelContext.save()
    }

    public func fetchAllTags() async throws -> [FlowTag] {
        let descriptor = FetchDescriptor<FlowTag>(
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor)
    }

    public func findOrCreateTag(name: String) async throws -> FlowTag {
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
