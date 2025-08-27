//
//  GameHeader.swift
//  QuizAI
//
//  Created by Oleh Zimin on 11.07.2025.
//

import SwiftUI

struct GameHeader: View {
    @Environment(GameService.self) private var gameService
    
    // MARK: Body
    var body: some View {
        Text("\(gameService.currentQuestionIndex + 1) / \(gameService.questions.count)")
        
        if gameService.timing.isTimed {
            Text("\(gameService.remainingQuestionTime)")
                .onChange(of: gameService.remainingQuestionTime) { oldValue, newValue in
                    if newValue == 0 {
                        // Methods used incorrectly
                        gameService.answer(with: "", isCorrect: false)
                        gameService.continueToNextQuestion()
                    }
                }
        }
            
    }
}

#Preview {
    let quiz = QuizModel.mockQuiz()
    GameService.shared.setGame(with: quiz, types: QuestionType.allCases, timing: .countdown(seconds: 10))
    
    return
    GameHeader()
        .environment(GameService.shared)
}
