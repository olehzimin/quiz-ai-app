//
//  QuestionView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 11.07.2025.
//

import SwiftUI

struct QuestionView: View {
    @Environment(GameService.self) private var gameService
    
    let columns: [GridItem] = [GridItem(), GridItem()]
    
    var body: some View {
        VStack {
            QuestionCard(question: gameService.currentQuestion)
                .frame(height: 360)
            
            LazyVGrid(columns: columns) {
                ForEach(Array(gameService.currentQuestion.options.enumerated()), id: \.offset) { index, option in
                    OptionButtonView(
                        option: option,
                        isCorrect: index == gameService.currentQuestion.answerIndex
                    ) {
                        gameService.isQuestionAnswered = true
                        if index == gameService.currentQuestion.answerIndex {
//                            gameService.currentQuestion.completed = true
                        }
                    }
                    .disabled(gameService.isQuestionAnswered)
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    if let quiz = QuizModel.mock {
        GameService.shared.startGame(with: quiz)
    }
    
    return QuestionView()
        .environment(GameService.shared)
}

fileprivate struct QuestionCard: View {
    let question: QuestionModel
    
    var body: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(Color.cyan)
            .overlay {
                ZStack {
                    Text(question.question)
                    
                    Text(question.type.rawValue)
                        .padding()
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
    }
}

fileprivate struct OptionButtonView: View {
    private enum ButtonState {
        case neutral, correct, wrong
        
        var color: Color {
            switch self {
            case .neutral:
                Color.secondary.opacity(0.3)
            case .correct:
                Color.green
            case .wrong:
                Color.red
            }
        }
    }
    
    let option: String
    let isCorrect: Bool
    let action: () -> Void
    
    init(option: String, isCorrect: Bool, action: @escaping () -> Void) {
        self.option = option
        self.isCorrect = isCorrect
        self.action = action
    }
    
    @State private var buttonState: ButtonState = .neutral
    @State private var isTapped: Bool = false
    
    @Environment(GameService.self) private var gameService
    
    var body: some View {
        Button {
//            isTapped = true
            action()
            if !isCorrect {
                buttonState = .wrong
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(buttonState.color)
                
                Text(option)
            }
            .frame(height: 80)
        }
        
        .onChange(of: gameService.isQuestionAnswered, updateButton)
        .buttonStyle(PressableButtonStyle())
    }
    
    private func updateButton() {
//        if !gameService.isQuestionAnswered {
//            isTapped = false
//            buttonState = .neutral
//        } else {
//            if isCorrect {
//                buttonState = .correct
//            } else if !isCorrect && isTapped {
//                buttonState = .wrong
//            }
//        }
        
        
        
        if gameService.isQuestionAnswered && isCorrect {
            buttonState = .correct
        } else if !gameService.isQuestionAnswered {
            buttonState = .neutral
        }
        
//        if gameService.isQuestionAnswered && isTaped && !isCorrect {
//            buttonState = .wrong
//        }
    }
}
