import Testing
import Foundation
@testable import Storage

// Placeholder for storage tests — requires SwiftData runtime.
@Suite("Storage")
struct StorageTests {
    @Test("FlowTask initializes with correct defaults")
    func taskDefaults() {
        let task = FlowTask(title: "Test task")
        #expect(task.title == "Test task")
        #expect(task.isCompleted == false)
        #expect(task.priority == .none)
        #expect(task.notes == "")
        #expect(task.isArchived == false)
        #expect(task.tags.isEmpty)
    }

    @Test("FlowProject tracks progress correctly")
    func projectProgress() {
        let project = FlowProject(name: "Test Project")
        #expect(project.progress == 0)
        #expect(project.remainingCount == 0)
    }

    @Test("TaskPriority has all expected cases")
    func priorityCases() {
        #expect(TaskPriority.allCases.count == 5)
        #expect(TaskPriority.none.rawValue == 0)
        #expect(TaskPriority.urgent.rawValue == 4)
    }
}
