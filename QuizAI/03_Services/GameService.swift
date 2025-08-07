//
//  GameService.swift
//  QuizAI
//
//  Created by Oleh Zimin on 11.07.2025.
//

import SwiftUI

@Observable
final class GameService {
    static let shared: GameService = GameService()
    private init() { print("GameService init") }
    
    deinit {
        print("GameService has been deleted")
    }
    
    private(set) var quiz: QuizModel? = nil
    private var questions: [QuestionModel] = []
    private(set) var currentQuestionIndex: Int = 0
    var currentQuestion: QuestionModel { questions[currentQuestionIndex] }
    
    var isQuestionAnswered: Bool = false
    var isQuizFinished: Bool { currentQuestionIndex + 1 == quiz?.questionsCount ?? 0 }
    
    func continueToNextQuestion() {
        if !isQuizFinished {
            currentQuestionIndex += 1
            isQuestionAnswered = false
        }
    }
    
    func startGame(with quiz: QuizModel) {
        self.quiz = quiz
        self.questions = []
        self.currentQuestionIndex = 0
        self.isQuestionAnswered = false
        
        do {
            try setGame()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func finishGame() {
        self.quiz = nil
        
    }
    
    private func setGame() throws {
        guard let quiz else { throw GameServiceError.missingQuiz }
        
        var questions: [QuestionModel] = quiz.questions.shuffled()
        
        for (index, var question) in questions.enumerated() {
            question = shuffledOptions(question: question)
            questions[index] = question
        }
        
        self.questions = questions
        
        print("setGame called")
    }
    
    private func shuffledOptions(question: QuestionModel) -> QuestionModel {
        var modifiedQuestion = question
        
        guard modifiedQuestion.type == .multichoice else { return question }

        let correctAnswer = modifiedQuestion.options[modifiedQuestion.answerIndex]
        modifiedQuestion.options.shuffle()
        
        if let newAnswerIndex = modifiedQuestion.options.firstIndex(of: correctAnswer) {
            modifiedQuestion.answerIndex =  newAnswerIndex
        } else {
            print("Error: rewriting answer index failed")
        }
        
        return modifiedQuestion
    }
    
//    private func finishGame() {
//        quiz.questions = self.questions
//    }
}

// MARK: Errors
enum GameServiceError: Error, LocalizedError {
    case missingQuiz
    
    var errorDescription: String? {
        switch self {
        case .missingQuiz:
            "The quiz was not set"
        }
    }
}
