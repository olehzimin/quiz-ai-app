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
    
    // MARK: Properties
    var isQuestionAnswered: Bool = false
    
    private(set) var quiz: QuizModel? = nil
    private(set) var timing: GameTiming = .unlimited
    private(set) var currentQuestionIndex: Int = 0
    
    private let timerService = TimerService()
    private var questions: [QuestionModel] = []
    
    private init() { print("GameService init") }
    
    var currentQuestion: QuestionModel? {
        if currentQuestionIndex < questions.count {
            return questions[currentQuestionIndex]
        } else {
            return nil
        }
        //        var index = currentQuestionIndex
        //
        //        while index >= quiz?.questionsCount ?? 0 {
        //            index -= 1
        //        }
        //
        //        return questions[index]
    }
    
    var isGameFinished: Bool {
        currentQuestionIndex >= questions.count
    }
    
    var gameScore: String {
        let completedQuestions: Int = questions.filter { $0.isCompleted == true }.count
        
        return String("\(completedQuestions)/\(questions.count)")
    }
    
    var remainingQuestionTime: Int {
        timerService.remainingTime
    }
    
    // MARK: Methods
    func continueToNextQuestion() {
        if !isGameFinished {
            currentQuestionIndex += 1
            isQuestionAnswered = false
            
            try? timerService.startTimer()
        } else {
            finishGame()
        }
        
        
    }
    
    func setGame(with quiz: QuizModel, timing: GameTiming) {
        self.quiz = quiz
        self.timing = timing
        
        self.currentQuestionIndex = 0
        self.isQuestionAnswered = false
        
        var questions: [QuestionModel] = quiz.questions.shuffled()
        for (index, var question) in questions.enumerated() {
            question = shuffledOptions(question: question)
            questions[index] = question
        }
        self.questions = questions
        
        if case .countdown(let seconds) = timing {
            timerService.setTimer(time: seconds)
        }
        print("setGame called")
    }
    
    func startGame() throws {
        guard let quiz else { throw GameServiceError.missingQuiz }
        
        try timerService.startTimer()
    }
    
    func finishGame() {
        self.quiz?.questions = self.questions
        quiz?.updateCache()
        
        print("game finished")
    }
    
    func answer(with option: String, isCorrect: Bool) {
        guard currentQuestionIndex < questions.count else { return }
        
        if isCorrect {
            questions[currentQuestionIndex].isCompleted = true
        } else {
            questions[currentQuestionIndex].isCompleted = false
        }
    }
    
    // MARK: Private Methods
    private func shuffledOptions(question: QuestionModel) -> QuestionModel {
        guard question.type == .multichoice else { return question }
        
        var modifiedQuestion = question
        modifiedQuestion.options.shuffle()
        
        return modifiedQuestion
    }
    
    private func setTimer() {
        
    }
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

