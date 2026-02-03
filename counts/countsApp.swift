//
//  countsApp.swift
//  counts
//
//  Created by Yaraslau Blonski on 3.02.26.
//

import SwiftUI

@main
struct countsApp: App {
    @StateObject private var countersViewModel = CountersViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(countersViewModel)
        }
    }
}
