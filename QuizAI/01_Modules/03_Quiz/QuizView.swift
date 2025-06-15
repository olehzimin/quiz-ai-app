//
//  QuizView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 13.06.2025.
//

import SwiftUI

struct QuizView: View {
    @Environment(\.modelContext) var modelContext
    
    let quiz: Quiz
    @Binding var path: NavigationPath
    @State private var currentIndex: Int = 0
    var currentQuestion: Question {
        quiz.questions[currentIndex]
    }
    @State private var isQuestionAnswered: Bool = false
    @Environment(\.dismiss) var dismiss
    
    let columns: [GridItem] = [GridItem(), GridItem()]
    
    
    var body: some View {
        VStack {
            Text("\(currentIndex + 1) / \(quiz.questionsCount)")
            
            Text("timer")
            
            QuestionCardView(question: currentQuestion)
                .frame(height: 360)
            
            LazyVGrid(columns: columns) {
                ForEach(Array(currentQuestion.options.enumerated()), id: \.offset) { index, option in
                    AnswerButtonView(
                        answer: option,
                        isCorrect: index == currentQuestion.answerIndex,
                        isQuestionAnswered: isQuestionAnswered
                    ) {
                        isQuestionAnswered = true
//                        if index == currentQuestion.answerIndex {
//                            currentQuestion.completed = true
//                        } else {
//                            currentQuestion.completed = false
//                        }
                    }
                    .disabled(isQuestionAnswered)
                }
            }
            .padding(.vertical)
            
            Spacer()
            
            Button {
                if currentIndex < quiz.questionsCount - 1 {
                    currentIndex += 1
                    isQuestionAnswered = false
                } else {
                    path.removeLast()
                }
            } label: {
                ZStack {
                    Capsule()
                    
                    Text("Continue")
                        .foregroundStyle(.white)
                }
                .frame(height: 60)
                .opacity(isQuestionAnswered ? 1 : 0)
            }
            .disabled(!isQuestionAnswered)
            .buttonStyle(PressableButtonStyle())
        }
        .padding(.horizontal)
        .navigationBarBackButtonHidden()
        .safeAreaInset(edge: .top) {
            HStack(spacing: 32) {
                Button {
                    path.removeLast()
                } label: {
                    Image(systemName: "xmark")
                }
                
                Spacer()
            }
            .font(.title2)
            .padding(.horizontal)
            .padding(.top, 32)
            .foregroundStyle(.black)
        }
    }
}

#Preview {
    if let quiz = Quiz.mock {
        QuizView(quiz: quiz, path: .constant(NavigationPath()))
    }
}

//fileprivate struct FlashcardView: View {
//    let question: Question
//    
//    var body: some View {
//        QuestionCardView(question: question)
//            .frame(height: 400)
//            .padding()
//    }
//}
//
//fileprivate struct MultichoiceView: View {
//    let question: Question
//    
//    var body: some View {
//        Text(question.question)
//            .foregroundStyle(.green)
//    }
//}
//
//fileprivate struct TrueFalseView: View {
//    let question: Question
//    
//    var body: some View {
//        Text(question.question)
//            .foregroundStyle(.blue)
//    }
//}

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
