import SwiftData
import Foundation

// MARK: - FlowTag Model
// Lightweight tagging system. Tags can be applied to any task.

@Model
public final class FlowTag: @unchecked Sendable {
    #Unique<FlowTag>([\.id])
    #Index<FlowTag>([\.name])

    public var id: UUID
    public var name: String
    public var colorIndex: Int
    public var createdAt: Date

    public var tasks: [FlowTask]

    public init(name: String, colorIndex: Int = 0) {
        self.id = UUID()
        self.name = name
        self.colorIndex = colorIndex
        self.createdAt = .now
        self.tasks = []
    }
}
