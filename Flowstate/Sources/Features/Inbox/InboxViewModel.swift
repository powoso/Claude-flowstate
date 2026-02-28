import SwiftUI
import SwiftData
import Observation
import Storage
import NLParser

// MARK: - Inbox ViewModel
// Manages inbox task list, NL input parsing, and task creation.

@Observable
@MainActor
public final class InboxViewModel {
    // MARK: - State
    public var tasks: [FlowTask] = []
    public var isLoading = false
    public var errorMessage: String?
    public var showingNewTask = false

    // NL Input
    public var inputText = ""
    public var parsedPreview: ParsedTask = ParsedTask()
    public var parsedEntities: [ParsedEntity] = []

    // MARK: - Dependencies
    private let repository: TaskRepositoryProtocol
    private let parser = NLTaskParser()

    public init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Actions

    public func loadTasks() async {
        isLoading = tasks.isEmpty
        errorMessage = nil

        do {
            tasks = try await repository.fetchInboxTasks()
        } catch {
            errorMessage = "Couldn't load your inbox. Pull to try again."
        }

        isLoading = false
    }

    public func createTaskFromInput() async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let parsed = parser.parse(trimmed)

        let task = FlowTask(
            title: parsed.title.isEmpty ? trimmed : parsed.title,
            priority: TaskPriority(rawValue: parsed.priority.rawValue) ?? .none,
            dueDate: parsed.combinedDateTime,
            estimatedMinutes: parsed.estimatedMinutes,
            locationName: parsed.locationName
        )

        do {
            // Create tags
            for tagName in parsed.tags {
                let tag = try await repository.findOrCreateTag(name: tagName)
                task.tags.append(tag)
            }

            try await repository.createTask(task)
            inputText = ""
            parsedPreview = ParsedTask()
            parsedEntities = []
            await loadTasks()
        } catch {
            errorMessage = "Couldn't create task. Please try again."
        }
    }

    public func updateParsedPreview() {
        guard !inputText.isEmpty else {
            parsedPreview = ParsedTask()
            parsedEntities = []
            return
        }
        let (parsed, entities) = parser.parseWithEntities(inputText)
        parsedPreview = parsed
        parsedEntities = entities
    }

    public func toggleComplete(_ task: FlowTask) async {
        do {
            if task.isCompleted {
                try await repository.uncompleteTask(task)
            } else {
                try await repository.completeTask(task)
            }
            await loadTasks()
        } catch {
            errorMessage = "Couldn't update task."
        }
    }

    public func deleteTask(_ task: FlowTask) async {
        do {
            try await repository.deleteTask(task)
            await loadTasks()
        } catch {
            errorMessage = "Couldn't delete task."
        }
    }
}
