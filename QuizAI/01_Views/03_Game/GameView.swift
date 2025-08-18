//
//  GameView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 13.06.2025.
//

import SwiftUI

struct GameView: View {
    @Environment(NavigationService.self) private var navigationService
    @Environment(GameService.self) var gameService
    @Environment(\.dismiss) var dismiss
    
    //MARK: Body
    var body: some View {
        VStack {
            if let question = gameService.currentQuestion {
                VStack {
                    GameHeader()
                    
                    QuestionView(question: question)
                    
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
                Text("Well done! \nYour score: \(gameService.gameScore)")
                    .frame(maxHeight: .infinity, alignment: .center)
                
                Spacer()
                
                Button {
                    gameService.finishGame()
                    navigationService.path.removeLast()
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
                    navigationService.path.removeLast()
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
        .onAppear {
            do {
                try gameService.startGame()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    let quiz = QuizModel.mockQuiz()
    GameService.shared.setGame(with: quiz, timing: .countdown(seconds: 10))
    
    return
    GameView()
        .environment(NavigationService())
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


