import Testing
import Foundation
@testable import NLParser

// MARK: - Natural Language Parser Tests
// Comprehensive tests for the parsing engine — the core differentiating feature.

@Suite("NLTaskParser")
struct NLTaskParserTests {
    let parser = NLTaskParser()

    // Fixed reference date for deterministic tests: 2025-01-15 10:00:00
    var referenceDate: Date {
        var components = DateComponents()
        components.year = 2025
        components.month = 1
        components.day = 15
        components.hour = 10
        components.minute = 0
        return Calendar.current.date(from: components)!
    }

    // MARK: - Basic Parsing

    @Test("Plain text becomes title")
    func plainText() {
        let result = parser.parse("Buy groceries")
        #expect(result.title == "Buy groceries")
        #expect(result.tags.isEmpty)
        #expect(result.priority == .none)
        #expect(result.date == nil)
    }

    @Test("Empty string returns empty result")
    func emptyString() {
        let result = parser.parse("")
        #expect(result.title == "")
    }

    // MARK: - Priority

    @Test("!high extracts high priority")
    func highPriority() {
        let result = parser.parse("Finish report !high")
        #expect(result.priority == .high)
        #expect(result.title == "Finish report")
    }

    @Test("!urgent extracts urgent priority")
    func urgentPriority() {
        let result = parser.parse("Fix production bug !urgent")
        #expect(result.priority == .urgent)
    }

    @Test("!low extracts low priority")
    func lowPriority() {
        let result = parser.parse("Read article !low")
        #expect(result.priority == .low)
    }

    @Test("!! extracts high priority")
    func doubleExclamation() {
        let result = parser.parse("Deploy hotfix !!")
        #expect(result.priority == .high)
    }

    @Test("!!! extracts urgent priority")
    func tripleExclamation() {
        let result = parser.parse("Server is down !!!")
        #expect(result.priority == .urgent)
    }

    // MARK: - Tags

    @Test("Single tag extraction")
    func singleTag() {
        let result = parser.parse("Review PR #work")
        #expect(result.tags == ["work"])
        #expect(result.title == "Review PR")
    }

    @Test("Multiple tags extraction")
    func multipleTags() {
        let result = parser.parse("Design mockup #work #design #urgent")
        #expect(result.tags == ["work", "design", "urgent"])
    }

    // MARK: - Dates

    @Test("'today' parses to today's date")
    func todayDate() {
        let result = parser.parse("Buy milk today", relativeTo: referenceDate)
        #expect(result.date != nil)
        let calendar = Calendar.current
        #expect(calendar.isDate(result.date!, inSameDayAs: referenceDate))
    }

    @Test("'tomorrow' parses to next day")
    func tomorrowDate() {
        let result = parser.parse("Meeting tomorrow", relativeTo: referenceDate)
        #expect(result.date != nil)
        let expectedDay = Calendar.current.date(byAdding: .day, value: 1, to: referenceDate)!
        let calendar = Calendar.current
        #expect(calendar.isDate(result.date!, inSameDayAs: expectedDay))
    }

    @Test("Day name parses to next occurrence")
    func dayName() {
        let result = parser.parse("Dentist monday", relativeTo: referenceDate)
        #expect(result.date != nil)
        let weekday = Calendar.current.component(.weekday, from: result.date!)
        #expect(weekday == 2) // Monday
    }

    @Test("Relative 'in 3 days' parses correctly")
    func relativeDays() {
        let result = parser.parse("Follow up in 3 days", relativeTo: referenceDate)
        #expect(result.date != nil)
        let expected = Calendar.current.date(byAdding: .day, value: 3, to: Calendar.current.startOfDay(for: referenceDate))!
        let calendar = Calendar.current
        #expect(calendar.isDate(result.date!, inSameDayAs: expected))
    }

    // MARK: - Time

    @Test("'at 3pm' parses time")
    func timeWithPM() {
        let result = parser.parse("Call Sarah at 3pm", relativeTo: referenceDate)
        #expect(result.time != nil)
        let hour = Calendar.current.component(.hour, from: result.time!)
        #expect(hour == 15)
    }

    @Test("'at 14:30' parses 24h time")
    func time24Hour() {
        let result = parser.parse("Meeting at 14:30", relativeTo: referenceDate)
        #expect(result.time != nil)
        let components = Calendar.current.dateComponents([.hour, .minute], from: result.time!)
        #expect(components.hour == 14)
        #expect(components.minute == 30)
    }

    // MARK: - Date + Time Combined

    @Test("'tomorrow at 3pm' combines date and time")
    func dateAndTime() {
        let result = parser.parse("Meeting tomorrow at 3pm", relativeTo: referenceDate)
        #expect(result.combinedDateTime != nil)
        let components = Calendar.current.dateComponents([.hour], from: result.combinedDateTime!)
        #expect(components.hour == 15)

        let expectedDay = Calendar.current.date(byAdding: .day, value: 1, to: referenceDate)!
        #expect(Calendar.current.isDate(result.combinedDateTime!, inSameDayAs: expectedDay))
    }

    // MARK: - Duration

    @Test("~30m parses to 30 minutes")
    func durationMinutes() {
        let result = parser.parse("Review code ~30m")
        #expect(result.estimatedMinutes == 30)
    }

    @Test("~2h parses to 120 minutes")
    func durationHours() {
        let result = parser.parse("Deep work session ~2h")
        #expect(result.estimatedMinutes == 120)
    }

    @Test("~1h30m parses to 90 minutes")
    func durationHoursAndMinutes() {
        let result = parser.parse("Workshop ~1h30m")
        #expect(result.estimatedMinutes == 90)
    }

    // MARK: - Location

    @Test("@Location parses location")
    func simpleLocation() {
        let result = parser.parse("Coffee meeting @Starbucks")
        #expect(result.locationName == "Starbucks")
    }

    @Test("@\"Quoted Location\" parses multi-word location")
    func quotedLocation() {
        let result = parser.parse("Run @\"Central Park\"")
        #expect(result.locationName == "Central Park")
    }

    // MARK: - Complex Input

    @Test("Full complex input parses all entities")
    func complexInput() {
        let result = parser.parse(
            "Meeting with Sarah tomorrow at 3pm @Starbucks #work !high ~30m",
            relativeTo: referenceDate
        )

        #expect(result.title == "Meeting with Sarah")
        #expect(result.priority == .high)
        #expect(result.tags == ["work"])
        #expect(result.estimatedMinutes == 30)
        #expect(result.locationName == "Starbucks")
        #expect(result.combinedDateTime != nil)

        let hour = Calendar.current.component(.hour, from: result.combinedDateTime!)
        #expect(hour == 15)
    }

    // MARK: - Entity Finding

    @Test("Entities are found with correct ranges")
    func entityFinding() {
        let input = "Buy groceries #personal !low"
        let (_, entities) = parser.parseWithEntities(input)

        let tagEntity = entities.first { $0.kind == .tag }
        #expect(tagEntity != nil)
        #expect(tagEntity?.value == "#personal")

        let priorityEntity = entities.first { $0.kind == .priority }
        #expect(priorityEntity != nil)
    }
}
