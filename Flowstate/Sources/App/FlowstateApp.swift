import SwiftUI
import DesignSystem
import Storage

// MARK: - App Entry Point

@main
struct FlowstateApp: App {
    private let container = DependencyContainer.shared
    @State private var coordinator: AppCoordinator

    init() {
        let container = DependencyContainer.shared
        _coordinator = State(initialValue: AppCoordinator(container: container))
    }

    var body: some Scene {
        WindowGroup {
            RootView(coordinator: coordinator)
                .modelContainer(container.modelContainer)
        }
    }
}

// MARK: - Root View

struct RootView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            Tab(AppTab.today.rawValue, systemImage: AppTab.today.icon, value: .today) {
                TodayView(viewModel: coordinator.makeTodayViewModel())
            }

            Tab(AppTab.inbox.rawValue, systemImage: AppTab.inbox.icon, value: .inbox) {
                InboxView(viewModel: coordinator.makeInboxViewModel())
            }

            Tab(AppTab.projects.rawValue, systemImage: AppTab.projects.icon, value: .projects) {
                placeholderView("Projects", icon: "folder.fill", message: "Coming in Phase 2")
            }

            Tab(AppTab.habits.rawValue, systemImage: AppTab.habits.icon, value: .habits) {
                placeholderView("Habits", icon: "flame.fill", message: "Coming in Phase 3")
            }

            Tab(AppTab.settings.rawValue, systemImage: AppTab.settings.icon, value: .settings) {
                placeholderView("Settings", icon: "gearshape.fill", message: "Coming in Phase 5")
            }
        }
        .tint(FlowColors.accentFallback)
    }

    private func placeholderView(_ title: String, icon: String, message: String) -> some View {
        NavigationStack {
            EmptyStateView(
                symbol: icon,
                title: title,
                message: message
            )
            .navigationTitle(title)
        }
    }
}

// MARK: - Imports for feature views
import Features
