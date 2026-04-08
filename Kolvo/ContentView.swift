//
//  ContentView.swift
//  Kolvo
//
//  Created by Yaraslau Blonski on 3.02.26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HomeView()
    }
}

#Preview {
    ContentView()
        .environmentObject(CountersViewModel())
}
