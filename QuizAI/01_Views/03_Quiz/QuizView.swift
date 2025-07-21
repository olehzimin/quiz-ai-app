//
//  QuizView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 13.06.2025.
//

import SwiftUI

struct QuizView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var path: NavigationPath
    @State private var viewModel: QuizViewModel
    
    init(quiz: Quiz, path: Binding<NavigationPath>) {
        _path = path
        _viewModel = State(wrappedValue: QuizViewModel(quiz: quiz))
    }
    
    var body: some View {
        VStack {
            if !viewModel.isQuizFinished {
                VStack {
                    HeaderQuizView(viewModel: viewModel, timer: true)
                    
                    QuestionView(viewModel: viewModel)
                }
            } else {
                Text("Well done! \nYour score: \(viewModel.quiz.completedQuestionsCount) / \(viewModel.quiz.questionsCount)")
                    .frame(maxHeight: .infinity, alignment: .center)
            }
            
            Spacer()
            
            if !viewModel.isQuizFinished {
                Button(action: viewModel.nextQuestion) {
                    ZStack {
                        Capsule()
                        
                        Text("Continue")
                            .foregroundStyle(.white)
                    }
                    .frame(height: 60)
                    .opacity(viewModel.isQuestionAnswered ? 1 : 0)
                }
                .disabled(!viewModel.isQuestionAnswered)
                .buttonStyle(PressableButtonStyle())
            } else {
                Button {
                    path.removeLast()
                } label: {
                    ZStack {
                        Capsule()
                        
                        Text("Continue")
                            .foregroundStyle(.white)
                    }
                    .frame(height: 60)
                }
                .buttonStyle(PressableButtonStyle())
            }
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


