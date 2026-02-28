# Flowstate

A production-grade iOS & macOS task manager built with SwiftUI, SwiftData, and Swift 6. Flowstate combines the simplicity of Apple Reminders with the power of Notion and the satisfying UX of Things 3.

## Requirements

| Requirement | Minimum |
|---|---|
| macOS | 15.0 (Sequoia) |
| iOS | 18.0 |
| Xcode | 16.0+ |
| Swift | 6.0 |
| Apple ID | Required for iCloud sync |

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/powoso/Claude-flowstate.git
cd Claude-flowstate/Flowstate
```

### 2. Open in Xcode

```bash
open Package.swift
```

Or open Xcode manually and select **File → Open** then navigate to the `Flowstate/` directory and open `Package.swift`.

Xcode will automatically resolve the SPM package graph. Wait for package resolution to complete (check the status bar at the top of Xcode).

### 3. Create an Xcode Project (if needed)

Since Flowstate is structured as a Swift Package, you may want to wrap it in an Xcode project for device builds:

1. In Xcode, select **File → New → Project**
2. Choose **App** under the iOS or macOS tab
3. Set the product name to `Flowstate`
4. Set the bundle identifier to `com.yourname.flowstate`
5. Select **SwiftData** for Storage and **SwiftUI** for Interface
6. After project creation, go to **File → Add Package Dependencies**
7. Click **Add Local** and select the `Flowstate/` directory from this repo
8. Add `DesignSystem`, `Storage`, `NLParser`, and `Features` libraries to your app target

### 4. Configure Signing

1. Select the project in the navigator
2. Go to the **Signing & Capabilities** tab
3. Select your **Team** (requires an Apple Developer account for device builds; a free account works for simulators)
4. Set a unique **Bundle Identifier** (e.g., `com.yourname.flowstate`)

### 5. Enable iCloud (Optional — for sync)

1. In **Signing & Capabilities**, click **+ Capability**
2. Add **iCloud**
3. Check **CloudKit**
4. Create or select a CloudKit container (e.g., `iCloud.com.yourname.flowstate`)

This enables seamless multi-device sync via SwiftData + CloudKit.

## Running the App

### iOS Simulator

1. Select an iOS 18+ simulator from the scheme dropdown (e.g., **iPhone 16 Pro**)
2. Press **⌘R** or click the **Run** button
3. The app launches in the simulator

### iOS Device

1. Connect your iPhone via USB or select it over Wi-Fi
2. Ensure your device runs **iOS 18.0 or later**
3. Select your device from the scheme dropdown
4. Press **⌘R** — Xcode will install and launch the app on your device

> **Note:** First-time device builds require trusting the developer certificate on the device: **Settings → General → VPN & Device Management → [Your Developer App]→ Trust**.

### macOS (Designed for iPad / Native)

Flowstate targets macOS 15+ via Mac Catalyst or native SwiftUI:

1. Select **My Mac (Designed for iPad)** or **My Mac** from the scheme dropdown
2. Press **⌘R**
3. The app runs natively on your Mac

## Project Structure

```
Flowstate/
├── Package.swift              # SPM manifest — all modules defined here
├── Sources/
│   ├── App/                   # Entry point, DI container, coordinator
│   ├── Core/
│   │   ├── DesignSystem/      # Colors, typography, spacing, components
│   │   ├── NLParser/          # Natural language task input parser
│   │   ├── Networking/        # CloudKit sync engine (Phase 4)
│   │   └── Storage/           # SwiftData models & TaskRepository
│   ├── Features/
│   │   ├── Inbox/             # Quick capture with NL input
│   │   ├── Today/             # Daily planner & morning briefing
│   │   ├── Projects/          # Project management (Phase 2)
│   │   ├── Habits/            # Habit tracking & streaks (Phase 3)
│   │   ├── FocusTimer/        # Pomodoro & focus sessions (Phase 3)
│   │   ├── Search/            # Global search (Phase 2)
│   │   ├── Settings/          # Preferences (Phase 5)
│   │   └── Onboarding/        # First-run experience (Phase 5)
│   ├── Widgets/               # Home & lock screen widgets (Phase 4)
│   ├── ShareExtension/        # Share sheet capture (Phase 4)
│   └── Intents/               # Siri & App Intents (Phase 4)
└── Tests/
    ├── CoreTests/             # NLParser & Storage tests
    └── FeatureTests/          # Feature-level tests
```

## SPM Modules

| Module | Description | Dependencies |
|---|---|---|
| `DesignSystem` | Color, typography, spacing tokens and reusable UI components | — |
| `NLParser` | Natural language date, priority, tag, and duration parser | — |
| `Storage` | SwiftData models and TaskRepository | `NLParser` |
| `Features` | All feature views and view models | `DesignSystem`, `Storage`, `NLParser` |

## Running Tests

```bash
# Run all tests from the command line
cd Flowstate
swift test

# Or in Xcode: ⌘U to run all tests
```

The NL parser module includes 20+ unit tests covering date parsing, time parsing, priority extraction, tag detection, and duration parsing.

## Architecture

- **MVVM-C** — Model-View-ViewModel-Coordinator pattern
- **Swift 6 strict concurrency** — `@ModelActor` for thread-safe data access, `Sendable` conformance throughout
- **Offline-first** — all writes go to local SwiftData first, CloudKit syncs in the background
- **Protocol-oriented** — `TaskRepositoryProtocol` enables dependency injection and test mocks
- **Design tokens** — every color, font, spacing, animation, and haptic is a named constant

## Troubleshooting

| Issue | Solution |
|---|---|
| Package resolution fails | **File → Packages → Reset Package Caches** in Xcode |
| Build errors after pull | Clean build folder: **⌘⇧K**, then rebuild: **⌘B** |
| iCloud sync not working | Verify CloudKit container is set up in the Apple Developer portal and the capability is enabled |
| Simulator runs slowly | Use **Release** build configuration for performance testing (Edit Scheme → Run → Build Configuration) |
| "Untrusted Developer" on device | **Settings → General → VPN & Device Management → Trust** your developer certificate |

## License

All rights reserved. This project is proprietary.
