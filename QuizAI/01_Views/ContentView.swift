//
//  ContentView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import SwiftUI

struct ContentView: View {
    @State private var path: NavigationPath = NavigationPath()
    @State private var gameService: GameService = GameService.shared
    
    var body: some View {
        NavigationStack(path: $path) {
            HomeView(path: $path)
        }
        .environment(gameService)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: QuizModel.self, inMemory: true)
}
