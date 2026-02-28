import SwiftData
import Foundation

// MARK: - Habit & HabitEntry Models
// Habit tracking with streak calculation and heat map data.

@Model
public final class FlowHabit: @unchecked Sendable {
    #Unique<FlowHabit>([\.id])

    public var id: UUID
    public var createdAt: Date
    public var updatedAt: Date

    public var name: String
    public var icon: String
    public var colorIndex: Int
    public var targetFrequency: String  // "daily", "weekdays", "3x_week", etc.
    public var reminderTime: Date?
    public var isArchived: Bool
    public var order: Int

    @Relationship(deleteRule: .cascade, inverse: \HabitEntry.habit)
    public var entries: [HabitEntry]

    // MARK: - Streak Calculation

    public var currentStreak: Int {
        let calendar = Calendar.current
        let sortedEntries = entries
            .filter(\.isCompleted)
            .sorted { $0.date > $1.date }

        guard let latest = sortedEntries.first else { return 0 }

        let today = calendar.startOfDay(for: .now)
        let latestDay = calendar.startOfDay(for: latest.date)

        // Must be today or yesterday to have an active streak
        let dayDiff = calendar.dateComponents([.day], from: latestDay, to: today).day ?? 0
        guard dayDiff <= 1 else { return 0 }

        var streak = 1
        var previousDate = latestDay

        for entry in sortedEntries.dropFirst() {
            let entryDay = calendar.startOfDay(for: entry.date)
            let diff = calendar.dateComponents([.day], from: entryDay, to: previousDate).day ?? 0

            if diff == 1 {
                streak += 1
                previousDate = entryDay
            } else if diff > 1 {
                break
            }
            // diff == 0 means same day, skip
        }

        return streak
    }

    public var longestStreak: Int {
        let calendar = Calendar.current
        let days = Set(entries.filter(\.isCompleted).map { calendar.startOfDay(for: $0.date) })
            .sorted()

        guard !days.isEmpty else { return 0 }

        var longest = 1
        var current = 1

        for i in 1..<days.count {
            let diff = calendar.dateComponents([.day], from: days[i - 1], to: days[i]).day ?? 0
            if diff == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }

        return longest
    }

    public init(
        name: String,
        icon: String = "circle.fill",
        colorIndex: Int = 0,
        targetFrequency: String = "daily"
    ) {
        self.id = UUID()
        self.createdAt = .now
        self.updatedAt = .now
        self.name = name
        self.icon = icon
        self.colorIndex = colorIndex
        self.targetFrequency = targetFrequency
        self.reminderTime = nil
        self.isArchived = false
        self.order = 0
        self.entries = []
    }
}

// MARK: - HabitEntry (single day's completion)

@Model
public final class HabitEntry: @unchecked Sendable {
    #Unique<HabitEntry>([\.id])

    public var id: UUID
    public var date: Date
    public var isCompleted: Bool
    public var completedAt: Date?
    public var notes: String

    public var habit: FlowHabit?

    public init(date: Date, isCompleted: Bool = true) {
        self.id = UUID()
        self.date = date
        self.isCompleted = isCompleted
        self.completedAt = isCompleted ? .now : nil
        self.notes = ""
    }
}
