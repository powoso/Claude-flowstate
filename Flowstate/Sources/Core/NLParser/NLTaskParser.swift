import Foundation

// MARK: - Natural Language Task Parser
// Parses free-form text like "Meeting with Sarah tomorrow at 3pm at Starbucks #work !high ~30m"
// into structured task components. Isolated module with no dependencies.

public struct ParsedTask: Sendable, Equatable {
    public var title: String
    public var date: Date?
    public var time: Date?            // Time component only
    public var combinedDateTime: Date? // Date + Time merged
    public var tags: [String]
    public var priority: ParsedPriority
    public var estimatedMinutes: Int?
    public var locationName: String?
    public var project: String?

    public init(
        title: String = "",
        date: Date? = nil,
        time: Date? = nil,
        combinedDateTime: Date? = nil,
        tags: [String] = [],
        priority: ParsedPriority = .none,
        estimatedMinutes: Int? = nil,
        locationName: String? = nil,
        project: String? = nil
    ) {
        self.title = title
        self.date = date
        self.time = time
        self.combinedDateTime = combinedDateTime
        self.tags = tags
        self.priority = priority
        self.estimatedMinutes = estimatedMinutes
        self.locationName = locationName
        self.project = project
    }
}

public enum ParsedPriority: Int, Sendable, Equatable {
    case none = 0
    case low = 1
    case medium = 2
    case high = 3
    case urgent = 4
}

/// Represents a parsed entity with its range in the original text for UI highlighting.
public struct ParsedEntity: Sendable, Equatable {
    public enum Kind: Sendable, Equatable {
        case date
        case time
        case tag
        case priority
        case duration
        case location
        case project
    }

    public let kind: Kind
    public let value: String
    public let range: Range<String.Index>
}

// MARK: - Parser

public final class NLTaskParser: Sendable {

    public init() {}

    /// Parse raw text into structured task data.
    public func parse(_ input: String, relativeTo referenceDate: Date = .now) -> ParsedTask {
        var remaining = input
        var result = ParsedTask()

        // Order matters: extract structured tokens first, leftover becomes title.
        let priority = extractPriority(&remaining)
        let tags = extractTags(&remaining)
        let duration = extractDuration(&remaining)
        let location = extractLocation(&remaining)
        let project = extractProject(&remaining)
        let dateTime = extractDateTime(&remaining, relativeTo: referenceDate)

        result.priority = priority
        result.tags = tags
        result.estimatedMinutes = duration
        result.locationName = location
        result.project = project
        result.date = dateTime.date
        result.time = dateTime.time
        result.combinedDateTime = dateTime.combined
        result.title = cleanTitle(remaining)

        return result
    }

    /// Parse and return both the result and entity positions for live UI highlighting.
    public func parseWithEntities(_ input: String, relativeTo referenceDate: Date = .now) -> (ParsedTask, [ParsedEntity]) {
        let result = parse(input, relativeTo: referenceDate)
        let entities = findEntities(in: input)
        return (result, entities)
    }

    // MARK: - Priority (!high, !urgent, !low, !med, !!, !!!, !)

    private func extractPriority(_ text: inout String) -> ParsedPriority {
        let patterns: [(String, ParsedPriority)] = [
            ("!urgent", .urgent), ("!!!", .urgent),
            ("!high", .high), ("!!", .high),
            ("!med", .medium), ("!medium", .medium),
            ("!low", .low), ("!", .low),
        ]

        for (pattern, priority) in patterns {
            if let range = text.range(of: pattern, options: .caseInsensitive) {
                // Make sure it's a word boundary (not part of another word)
                let afterEnd = range.upperBound
                if afterEnd == text.endIndex || text[afterEnd].isWhitespace {
                    text.removeSubrange(range)
                    return priority
                }
            }
        }
        return .none
    }

    // MARK: - Tags (#work, #personal)

    private func extractTags(_ text: inout String) -> [String] {
        var tags: [String] = []
        let pattern = #"#(\w+)"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else { return tags }
        let nsText = text as NSString
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))

        for match in matches.reversed() {
            if let tagRange = Range(match.range(at: 1), in: text) {
                tags.insert(String(text[tagRange]), at: 0)
            }
            if let fullRange = Range(match.range, in: text) {
                text.removeSubrange(fullRange)
            }
        }
        return tags
    }

    // MARK: - Duration (~30m, ~1h, ~1h30m, ~90min)

    private func extractDuration(_ text: inout String) -> Int? {
        let pattern = #"~(\d+)\s*(h|hr|hrs|hour|hours|m|min|mins|minutes?)(?:(\d+)\s*(m|min|mins|minutes?))?"#

        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { return nil }
        let nsText = text as NSString
        guard let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: nsText.length)) else { return nil }

        guard let fullRange = Range(match.range, in: text),
              let numRange = Range(match.range(at: 1), in: text),
              let unitRange = Range(match.range(at: 2), in: text) else { return nil }

        let number = Int(text[numRange]) ?? 0
        let unit = String(text[unitRange]).lowercased()

        var totalMinutes: Int
        if unit.hasPrefix("h") {
            totalMinutes = number * 60
            // Check for additional minutes (e.g., ~1h30m)
            if match.range(at: 3).location != NSNotFound,
               let addMinRange = Range(match.range(at: 3), in: text) {
                totalMinutes += Int(text[addMinRange]) ?? 0
            }
        } else {
            totalMinutes = number
        }

        text.removeSubrange(fullRange)
        return totalMinutes > 0 ? totalMinutes : nil
    }

    // MARK: - Location (@Starbucks, @"Central Park")

    private func extractLocation(_ text: inout String) -> String? {
        // @"quoted location"
        if let regex = try? NSRegularExpression(pattern: #"@"([^"]+)""#),
           let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: (text as NSString).length)),
           let fullRange = Range(match.range, in: text),
           let nameRange = Range(match.range(at: 1), in: text) {
            let location = String(text[nameRange])
            text.removeSubrange(fullRange)
            return location
        }

        // @SingleWord
        if let regex = try? NSRegularExpression(pattern: #"@(\w+)"#),
           let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: (text as NSString).length)),
           let fullRange = Range(match.range, in: text),
           let nameRange = Range(match.range(at: 1), in: text) {
            let word = String(text[nameRange]).lowercased()
            // Skip if it's a known date/time keyword
            let dateKeywords: Set<String> = ["today", "tomorrow", "monday", "tuesday", "wednesday",
                                              "thursday", "friday", "saturday", "sunday"]
            guard !dateKeywords.contains(word) else { return nil }
            let location = String(text[nameRange])
            text.removeSubrange(fullRange)
            return location
        }

        return nil
    }

    // MARK: - Project (// project name, /project)

    private func extractProject(_ text: inout String) -> String? {
        // //Project Name (rest of token until next special char)
        let pattern = #"//(\w[\w\s]*\w|\w+)"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: (text as NSString).length)),
              let fullRange = Range(match.range, in: text),
              let nameRange = Range(match.range(at: 1), in: text) else { return nil }

        let project = String(text[nameRange]).trimmingCharacters(in: .whitespaces)
        text.removeSubrange(fullRange)
        return project
    }

    // MARK: - Date/Time Extraction

    private struct DateTimeResult {
        var date: Date?
        var time: Date?
        var combined: Date?
    }

    private func extractDateTime(_ text: inout String, relativeTo now: Date) -> DateTimeResult {
        var result = DateTimeResult()
        let calendar = Calendar.current

        // Named days: "today", "tomorrow", "yesterday"
        if let range = text.range(of: "today", options: .caseInsensitive) {
            result.date = calendar.startOfDay(for: now)
            text.removeSubrange(range)
        } else if let range = text.range(of: "tomorrow", options: .caseInsensitive) {
            result.date = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
            text.removeSubrange(range)
        } else if let range = text.range(of: "yesterday", options: .caseInsensitive) {
            result.date = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: now))
            text.removeSubrange(range)
        }

        // Day names: "monday", "tuesday", etc.
        let dayNames = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"]
        for (index, dayName) in dayNames.enumerated() {
            let weekday = index + 1  // Calendar weekdays are 1-based (Sunday=1)
            if let range = text.range(of: dayName, options: .caseInsensitive) {
                result.date = nextWeekday(weekday, from: now)
                text.removeSubrange(range)
                break
            }
        }

        // "next week" -> next Monday
        if let range = text.range(of: "next week", options: .caseInsensitive) {
            result.date = nextWeekday(2, from: now) // Monday
            text.removeSubrange(range)
        }

        // Relative: "in 3 days", "in 2 weeks"
        let relativePattern = #"in\s+(\d+)\s+(day|days|week|weeks|month|months)"#
        if let regex = try? NSRegularExpression(pattern: relativePattern, options: .caseInsensitive),
           let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: (text as NSString).length)),
           let fullRange = Range(match.range, in: text),
           let numRange = Range(match.range(at: 1), in: text),
           let unitRange = Range(match.range(at: 2), in: text) {
            let num = Int(text[numRange]) ?? 0
            let unit = String(text[unitRange]).lowercased()
            let component: Calendar.Component = unit.hasPrefix("day") ? .day : unit.hasPrefix("week") ? .weekOfYear : .month
            result.date = calendar.date(byAdding: component, value: num, to: calendar.startOfDay(for: now))
            text.removeSubrange(fullRange)
        }

        // Time: "at 3pm", "at 14:30", "3:00pm", "15:00"
        let timePatterns = [
            #"(?:at\s+)?(\d{1,2}):(\d{2})\s*(am|pm)"#,
            #"(?:at\s+)?(\d{1,2})\s*(am|pm)"#,
            #"at\s+(\d{1,2}):(\d{2})"#,
            #"at\s+(\d{1,2})"#,
        ]

        for pattern in timePatterns {
            guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
                  let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: (text as NSString).length)),
                  let fullRange = Range(match.range, in: text),
                  let hourRange = Range(match.range(at: 1), in: text) else { continue }

            var hour = Int(text[hourRange]) ?? 0
            var minute = 0

            if match.numberOfRanges > 2, match.range(at: 2).location != NSNotFound,
               let minRange = Range(match.range(at: 2), in: text) {
                let minStr = String(text[minRange])
                if let m = Int(minStr) {
                    minute = m
                } else if minStr.lowercased() == "pm" && hour < 12 {
                    hour += 12
                } else if minStr.lowercased() == "am" && hour == 12 {
                    hour = 0
                }
            }

            if match.numberOfRanges > 3, match.range(at: 3).location != NSNotFound,
               let ampmRange = Range(match.range(at: 3), in: text) {
                let ampm = String(text[ampmRange]).lowercased()
                if ampm == "pm" && hour < 12 { hour += 12 }
                if ampm == "am" && hour == 12 { hour = 0 }
            }

            // For "at 3" without am/pm, assume PM if hour <= 6, AM if > 6
            if !text[fullRange].lowercased().contains("am") && !text[fullRange].lowercased().contains("pm") && hour <= 6 {
                hour += 12
            }

            result.time = calendar.date(bySettingHour: hour, minute: minute, second: 0, of: now)
            text.removeSubrange(fullRange)
            break
        }

        // Combine date + time
        if let date = result.date, let time = result.time {
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            result.combined = calendar.date(bySettingHour: timeComponents.hour ?? 0,
                                            minute: timeComponents.minute ?? 0,
                                            second: 0, of: date)
        } else if let date = result.date {
            result.combined = date
        } else if let time = result.time {
            result.combined = time
        }

        return result
    }

    private func nextWeekday(_ weekday: Int, from date: Date) -> Date {
        let calendar = Calendar.current
        let current = calendar.component(.weekday, from: date)
        var daysToAdd = weekday - current
        if daysToAdd <= 0 { daysToAdd += 7 }
        return calendar.date(byAdding: .day, value: daysToAdd, to: calendar.startOfDay(for: date))!
    }

    // MARK: - Entity Finding (for UI highlighting)

    private func findEntities(in text: String) -> [ParsedEntity] {
        var entities: [ParsedEntity] = []

        // Tags
        if let regex = try? NSRegularExpression(pattern: #"#\w+"#) {
            let matches = regex.matches(in: text, range: NSRange(location: 0, length: (text as NSString).length))
            for match in matches {
                if let range = Range(match.range, in: text) {
                    entities.append(.init(kind: .tag, value: String(text[range]), range: range))
                }
            }
        }

        // Priority
        let priorityPatterns = [#"!!!|!!|!urgent|!high|!med(?:ium)?|!low|!"#]
        for pattern in priorityPatterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: (text as NSString).length)),
               let range = Range(match.range, in: text) {
                entities.append(.init(kind: .priority, value: String(text[range]), range: range))
            }
        }

        // Duration
        if let regex = try? NSRegularExpression(pattern: #"~\d+\s*(?:h|hr|hrs|m|min|mins)(?:\d+\s*(?:m|min|mins))?"#, options: .caseInsensitive),
           let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: (text as NSString).length)),
           let range = Range(match.range, in: text) {
            entities.append(.init(kind: .duration, value: String(text[range]), range: range))
        }

        // Location
        if let regex = try? NSRegularExpression(pattern: #"@"[^"]+"|@\w+"#),
           let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: (text as NSString).length)),
           let range = Range(match.range, in: text) {
            entities.append(.init(kind: .location, value: String(text[range]), range: range))
        }

        return entities
    }

    // MARK: - Title Cleanup

    private func cleanTitle(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: #"\s{2,}"#, with: " ", options: .regularExpression)
    }
}
