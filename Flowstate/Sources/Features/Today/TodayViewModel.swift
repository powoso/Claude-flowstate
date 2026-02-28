import SwiftUI
import Observation
import Storage

// MARK: - Today ViewModel
// Morning briefing: overdue, today's tasks, greeting, and stats.

@Observable
@MainActor
public final class TodayViewModel {
    // MARK: - State
    public var overdueTasks: [FlowTask] = []
    public var todayTasks: [FlowTask] = []
    public var completedToday: [FlowTask] = []
    public var isLoading = false
    public var errorMessage: String?

    // MARK: - Dependencies
    private let repository: TaskRepositoryProtocol

    public init(repository: TaskRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Computed

    public var greeting: String {
        let hour = Calendar.current.component(.hour, from: .now)
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<22: return "Good evening"
        default: return "Good night"
        }
    }

    public var totalTasksToday: Int {
        overdueTasks.count + todayTasks.count
    }

    public var completedCountToday: Int {
        completedToday.count
    }

    public var briefingSummary: String {
        var parts: [String] = []

        if !overdueTasks.isEmpty {
            parts.append("\(overdueTasks.count) overdue")
        }

        let remaining = todayTasks.filter { !$0.isCompleted }
        if !remaining.isEmpty {
            parts.append("\(remaining.count) planned")
        }

        if !completedToday.isEmpty {
            parts.append("\(completedToday.count) done")
        }

        if parts.isEmpty {
            return "Nothing planned for today"
        }

        return parts.joined(separator: " · ")
    }

    // MARK: - Actions

    public func loadToday() async {
        isLoading = overdueTasks.isEmpty && todayTasks.isEmpty
        errorMessage = nil

        do {
            async let overdueResult = repository.fetchOverdueTasks()
            async let todayResult = repository.fetchTodayTasks()

            overdueTasks = try await overdueResult
            todayTasks = try await todayResult

            // Get completed today separately
            let allToday = try await repository.fetchTodayTasks()
            completedToday = allToday.filter(\.isCompleted)
        } catch {
            errorMessage = "Couldn't load today's plan. Pull to try again."
        }

        isLoading = false
    }

    public func toggleComplete(_ task: FlowTask) async {
        do {
            if task.isCompleted {
                try await repository.uncompleteTask(task)
            } else {
                try await repository.completeTask(task)
            }
            await loadToday()
        } catch {
            errorMessage = "Couldn't update task."
        }
    }

    public func scheduleForToday(_ task: FlowTask) async {
        task.scheduledDate = Calendar.current.startOfDay(for: .now)
        do {
            try await repository.updateTask(task)
            await loadToday()
        } catch {
            errorMessage = "Couldn't schedule task."
        }
    }
}
