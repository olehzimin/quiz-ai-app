//
//  GameView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 13.06.2025.
//

import SwiftUI

struct GameView: View {
    // MARK: delete quiz passing
    let quiz: QuizModel
    @Binding var path: NavigationPath
    
    
    init(quiz: QuizModel, path: Binding<NavigationPath>) {
        self.quiz = quiz
        _path = path
        print("Creation of GameView")
    }
    
    @Environment(GameService.self) var gameService
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            if !gameService.isQuizFinished {
                VStack {
                    GameHeader(showsTimer: true)
                    
                    QuestionView()
                    
                    Spacer()
                    
                    Button(action: gameService.continueToNextQuestion) {
                        ZStack {
                            Capsule()
                            
                            Text("Continue")
                                .foregroundStyle(.white)
                        }
                        .frame(height: 60)
                        .opacity(gameService.isQuestionAnswered ? 1 : 0)
                    }
                    .disabled(!gameService.isQuestionAnswered)
                    .buttonStyle(PressableButtonStyle())
                }
            } else {
                Text("Well done! \nYour score: \(quiz.completedQuestionsCount) / \(quiz.questionsCount)")
                    .frame(maxHeight: .infinity, alignment: .center)
                
                Spacer()
                
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
        .environment(gameService)
        .navigationBarBackButtonHidden()
        .safeAreaInset(edge: .top) {
            HStack(spacing: 32) {
                Button {
//                    quiz.updateCompletedQuestions()
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
    guard let quiz = QuizModel.mock else { return ProgressView() }
    GameService.shared.startGame(with: quiz)
    
    return GameView(quiz: quiz, path: .constant(NavigationPath()))
        .environment(GameService.shared)
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


