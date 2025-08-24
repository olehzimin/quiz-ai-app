//
//  ContentView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @State private var navigationService = NavigationService.shared
    @State private var quizService = QuizService.shared
    @State private var gameService: GameService = GameService.shared
    
    var body: some View {
        NavigationStack(path: $navigationService.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .add:
                        AddView()
                    case .edit(quiz: let quiz):
                        EditView(quiz: quiz)
                    case .game(quiz: let quiz):
                        GameView()
                    }
                }
        }
        .onAppear {
            quizService.set(modelContext: modelContext)
        }
        .environment(navigationService)
        .environment(gameService)
        .environment(quizService)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: QuizModel.self, inMemory: true)
}
