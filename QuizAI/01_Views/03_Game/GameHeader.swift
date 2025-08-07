//
//  GameHeader.swift
//  QuizAI
//
//  Created by Oleh Zimin on 11.07.2025.
//

import SwiftUI

struct GameHeader: View {
    var showsTimer: Bool
    
    @Environment(GameService.self) private var gameService
    
    // MARK: Unwrap
    var body: some View {
        Text("\(gameService.currentQuestionIndex + 1) / \(gameService.quiz!.questionsCount)")
        
        if showsTimer {
            Text("timer")
        }
    }
}

#Preview {
    if let quiz = QuizModel.mock {
        GameService.shared.startGame(with: quiz)
    }
    
    return GameHeader(showsTimer: true)
        .environment(GameService.shared)
}
