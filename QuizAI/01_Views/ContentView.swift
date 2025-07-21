//
//  ContentView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var path: NavigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Quiz.self, inMemory: true)
}
