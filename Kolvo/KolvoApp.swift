//
//  KolvoApp.swift
//  Kolvo
//
//  Created by Yaraslau Blonski on 3.02.26.
//

import SwiftUI

@main
struct KolvoApp: App {
    @StateObject private var countersViewModel = CountersViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(countersViewModel)
        }
    }
}
