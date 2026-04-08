//
//  CountersViewModel.swift
//  Kolvo
//

import Foundation

@MainActor
final class CountersViewModel: ObservableObject {
    @Published var counters: [Counter] = []

    let maxFreeCounters = 5

    private let persistence = PersistenceService.shared

    var canAddCounter: Bool {
        counters.count < maxFreeCounters
    }

    init() {
        load()
    }

    func load() {
        counters = persistence.load()
    }

    func save() {
        persistence.save(counters)
    }

    func add(counter: Counter) {
        counters.append(counter)
        save()
    }

    func delete(counter: Counter) {
        counters.removeAll { $0.id == counter.id }
        save()
    }

    func update(counter: Counter) {
        if let index = counters.firstIndex(where: { $0.id == counter.id }) {
            counters[index] = counter
            save()
        }
    }
}
