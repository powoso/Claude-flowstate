import SwiftData
import Foundation

// MARK: - FocusSession Model
// Tracks focus/pomodoro sessions linked to tasks.

@Model
public final class FocusSession: @unchecked Sendable {
    #Unique<FocusSession>([\.id])

    public var id: UUID
    public var startedAt: Date
    public var endedAt: Date?
    public var plannedSeconds: Int
    public var actualSeconds: Int
    public var sessionType: String  // "pomodoro", "custom", "open"

    public var taskID: UUID?
    public var notes: String

    public var isCompleted: Bool {
        endedAt != nil
    }

    public var duration: TimeInterval {
        guard let endedAt else {
            return Date.now.timeIntervalSince(startedAt)
        }
        return endedAt.timeIntervalSince(startedAt)
    }

    public init(
        plannedSeconds: Int,
        sessionType: String = "pomodoro",
        taskID: UUID? = nil
    ) {
        self.id = UUID()
        self.startedAt = .now
        self.endedAt = nil
        self.plannedSeconds = plannedSeconds
        self.actualSeconds = 0
        self.sessionType = sessionType
        self.taskID = taskID
        self.notes = ""
    }
}
