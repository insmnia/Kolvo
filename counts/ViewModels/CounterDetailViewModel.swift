//
//  CounterDetailViewModel.swift
//  counts
//

import Foundation

@MainActor
final class CounterDetailViewModel: ObservableObject {
    @Published var counter: Counter

    private let onUpdate: (Counter) -> Void
    private let onDelete: (Counter) -> Void

    init(counter: Counter, onUpdate: @escaping (Counter) -> Void, onDelete: @escaping (Counter) -> Void) {
        self.counter = counter
        self.onUpdate = onUpdate
        self.onDelete = onDelete
    }

    var displayValue: String {
        switch counter.type {
        case .manual:
            return "\(counter.manualValue)"
        case .auto:
            return "\(calculateAutoValue())"
        }
    }

    var subtextLabel: String {
        switch counter.type {
        case .manual:
            return "all time"
        case .auto:
            return "since \(formattedStartDate)"
        }
    }

    var formattedStartDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: counter.startDate)
    }

    func increment() {
        guard counter.type == .manual else { return }
        counter.manualValue += 1
        onUpdate(counter)
    }

    func reset() {
        switch counter.type {
        case .manual:
            counter.manualValue = 0
        case .auto:
            counter.startDate = Date()
        }
        onUpdate(counter)
    }

    func updateName(_ name: String) {
        counter.name = name
        onUpdate(counter)
    }

    func updateUnit(_ unit: TimeUnit) {
        counter.unit = unit
        onUpdate(counter)
    }

    func delete() {
        onDelete(counter)
    }

    func calculateAutoValue() -> Int {
        let unit = counter.unit ?? .days
        return unit.calculate(from: counter.startDate)
    }
}
