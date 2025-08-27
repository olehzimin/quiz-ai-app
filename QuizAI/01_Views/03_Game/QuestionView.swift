//
//  QuestionView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 11.07.2025.
//

import SwiftUI

struct QuestionView: View {
    let question: QuestionModel
    @Environment(GameService.self) private var gameService
    
    let columns: [GridItem] = [GridItem(), GridItem()]
    
    var body: some View {
        VStack {
            QuestionCard(question: question)
                .frame(height: 360)
            
            LazyVGrid(columns: columns) {
                ForEach(Array(question.options.enumerated()), id: \.offset) { index, option in
                    OptionButton(option: option)
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    let quiz = QuizModel.mockQuiz()
    GameService.shared.setGame(with: quiz, types: QuestionType.allCases, timing: .countdown(seconds: 10))
    
    guard let question = quiz.questions.first else {
        return ProgressView()
    }
    
    return QuestionView(question: question)
        .environment(GameService.shared)
}

fileprivate struct QuestionCard: View {
    let question: QuestionModel
    
    @State private var isFlipped: Bool = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 32)
            .fill(isFlipped ? Color.yellow : Color.cyan)
            .overlay {
                ZStack {
                    Text(isFlipped ? question.explanation : question.question)
                    
                    Text(question.type.rawValue)
                        .padding()
                        .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .onTapGesture {
                if question.type == .flashcard {
                    isFlipped.toggle()
                }
            }
            .onChange(of: question.id) { _, _ in
                isFlipped = false
            }
    }
}

fileprivate struct OptionButton: View {
    let option: QuestionOption
    
    @State private var buttonState: ButtonState = .neutral
    @State private var isTapped: Bool = false
    
    @Environment(GameService.self) private var gameService
    
    // Rewrite with new QuestionOption type
    var body: some View {
        Button {
//            isTapped = true
            gameService.answer(with: option.text, isCorrect: option.isCorrect)
            gameService.isQuestionAnswered = true
            if !option.isCorrect {
                buttonState = .wrong
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(buttonState.color)
                
                Text(option.text)
            }
            .frame(height: 80)
        }
        .disabled(gameService.isQuestionAnswered)
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
        
        
        
        if gameService.isQuestionAnswered && option.isCorrect {
            buttonState = .correct
//            gameService.currentQuestion.isCompleted = true
        } else if !gameService.isQuestionAnswered {
            buttonState = .neutral
        }
        
//        if gameService.isQuestionAnswered && isTaped && !isCorrect {
//            buttonState = .wrong
//        }
    }
    
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
}
