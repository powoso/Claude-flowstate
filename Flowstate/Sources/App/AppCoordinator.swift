import SwiftUI
import Observation
import Storage

// MARK: - App Coordinator
// Manages top-level navigation. No hardcoded navigation in views.

public enum AppTab: String, CaseIterable, Identifiable {
    case today = "Today"
    case inbox = "Inbox"
    case projects = "Projects"
    case habits = "Habits"
    case settings = "Settings"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .today: "sun.max.fill"
        case .inbox: "tray.fill"
        case .projects: "folder.fill"
        case .habits: "flame.fill"
        case .settings: "gearshape.fill"
        }
    }
}

@Observable
@MainActor
public final class AppCoordinator {
    public var selectedTab: AppTab = .today
    public var showingQuickAdd = false

    private let container: DependencyContainer

    public init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - ViewModel Factory

    public func makeInboxViewModel() -> InboxViewModel {
        InboxViewModel(repository: container.taskRepository)
    }

    public func makeTodayViewModel() -> TodayViewModel {
        TodayViewModel(repository: container.taskRepository)
    }
}
