//
//  QuestionView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 11.07.2025.
//

import SwiftUI

struct QuestionView: View {
    let viewModel: QuizViewModel
    
    let columns: [GridItem] = [GridItem(), GridItem()]
    
    var body: some View {
        VStack {
            QuestionCardView(question: viewModel.currentQuestion)
                .frame(height: 360)
            
            LazyVGrid(columns: columns) {
                ForEach(Array(viewModel.currentQuestion.options.enumerated()), id: \.offset) { index, option in
                    AnswerButtonView(
                        answer: option,
                        isCorrect: index == viewModel.currentQuestion.answerIndex,
                        isQuestionAnswered: viewModel.isQuestionAnswered
                    ) {
                        viewModel.isQuestionAnswered = true
                        if index == viewModel.currentQuestion.answerIndex {
//                            quiz.completedQuestionsCount += 1
                        }
                    }
                    .disabled(viewModel.isQuestionAnswered)
                }
            }
            .padding(.vertical)
        }
    }
}

#Preview {
    if let quiz = Quiz.mock {
        QuestionView(viewModel: QuizViewModel(quiz: quiz))
    }
}

fileprivate struct QuestionCardView: View {
    let question: Question
    
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

fileprivate struct AnswerButtonView: View {
    let answer: String
    let isCorrect: Bool
    let isQuestionAnswered: Bool
    let action: () -> Void
    @State private var buttonState: ButtonState = .neutral
    
    init(answer: String, isCorrect: Bool, isQuestionAnswered: Bool, action: @escaping () -> Void) {
        self.answer = answer
        self.isCorrect = isCorrect
        self.isQuestionAnswered = isQuestionAnswered
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
            if !isCorrect {
                buttonState = .wrong
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(buttonState.color)
                
                Text(answer)
            }
            .frame(height: 80)
        }
        .onChange(of: isQuestionAnswered, updateButton)
        .buttonStyle(PressableButtonStyle())
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
    
    private func updateButton() {
        if isQuestionAnswered && isCorrect {
            buttonState = .correct
        } else if !isQuestionAnswered {
            buttonState = .neutral
        }
    }
}
