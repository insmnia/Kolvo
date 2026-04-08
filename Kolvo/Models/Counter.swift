//
//  Counter.swift
//  Kolvo
//

import Foundation

struct Counter: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var type: CounterType
    var createdAt: Date
    var startDate: Date
    var manualValue: Int
    var unit: TimeUnit?

    init(
        id: UUID = UUID(),
        name: String,
        type: CounterType,
        createdAt: Date = Date(),
        startDate: Date = Date(),
        manualValue: Int = 0,
        unit: TimeUnit? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.createdAt = createdAt
        self.startDate = startDate
        self.manualValue = manualValue
        self.unit = unit
    }
}

enum CounterType: String, Codable, CaseIterable {
    case auto
    case manual

    var displayName: String {
        switch self {
        case .auto: return "Auto"
        case .manual: return "Manual"
        }
    }
}

enum TimeUnit: String, Codable, CaseIterable {
    case seconds
    case minutes
    case hours
    case days
    case weeks
    case months

    var displayName: String {
        switch self {
        case .seconds: return "Seconds"
        case .minutes: return "Minutes"
        case .hours: return "Hours"
        case .days: return "Days"
        case .weeks: return "Weeks"
        case .months: return "Months"
        }
    }

    var singularName: String {
        switch self {
        case .seconds: return "second"
        case .minutes: return "minute"
        case .hours: return "hour"
        case .days: return "day"
        case .weeks: return "week"
        case .months: return "month"
        }
    }

    var shortName: String {
        switch self {
        case .seconds: return "sec"
        case .minutes: return "min"
        case .hours: return "hr"
        case .days: return "d"
        case .weeks: return "wk"
        case .months: return "mo"
        }
    }

    func calculate(from startDate: Date, to endDate: Date = Date()) -> Int {
        let elapsed = endDate.timeIntervalSince(startDate)
        guard elapsed > 0 else { return 0 }

        switch self {
        case .seconds:
            return Int(elapsed)
        case .minutes:
            return Int(elapsed / 60)
        case .hours:
            return Int(elapsed / 3600)
        case .days:
            return Int(elapsed / 86400)
        case .weeks:
            return Int(elapsed / 604800)
        case .months:
            let calendar = Calendar.current
            let components = calendar.dateComponents([.month], from: startDate, to: endDate)
            return components.month ?? 0
        }
    }

    var timerInterval: TimeInterval {
        switch self {
        case .seconds: return 1
        case .minutes: return 1
        case .hours: return 60
        case .days: return 60
        case .weeks: return 300
        case .months: return 3600
        }
    }
}
