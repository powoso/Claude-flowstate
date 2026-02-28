import SwiftUI
import SwiftData
import Storage

// MARK: - Dependency Injection Container
// Single source of truth for all dependencies.
// Only singleton in the app — everything else is injected.

@MainActor
public final class DependencyContainer: Observable {
    // MARK: - Shared Instance
    public static let shared = DependencyContainer()

    // MARK: - Core
    public let modelContainer: ModelContainer
    public let taskRepository: TaskRepositoryProtocol

    // MARK: - Feature Flags
    public var featureFlags = FeatureFlags()

    private init() {
        do {
            modelContainer = try FlowModelContainer.create()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        taskRepository = SwiftDataTaskRepository(modelContainer: modelContainer)
    }

    // MARK: - Test Support
    public init(inMemory: Bool) {
        do {
            modelContainer = try FlowModelContainer.create(inMemory: true)
        } catch {
            fatalError("Failed to create in-memory ModelContainer: \(error)")
        }

        taskRepository = SwiftDataTaskRepository(modelContainer: modelContainer)
    }
}

// MARK: - Feature Flags

public struct FeatureFlags: Sendable {
    public var enableFocusTimer = true
    public var enableHabits = true
    public var enableCalendarIntegration = false  // Phase 4
    public var enableCloudSync = true
    public var enableSiriShortcuts = false        // Phase 4
    public var enableWidgets = false               // Phase 4
}
