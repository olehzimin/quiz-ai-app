//
//  QuizViewModel.swift
//  QuizAI
//
//  Created by Oleh Zimin on 11.07.2025.
//

import Foundation

@Observable
class QuizViewModel {
    let quiz: Quiz
    
    init(quiz: Quiz) {
        self.quiz = quiz
        startQuiz()
        print("QuizViewModel init")
    }
    
    var currentQuestionIndex: Int = 0
    
    var currentQuestion: Question {
        quiz.questions[currentQuestionIndex]
    }
    
    var isQuestionAnswered: Bool = false
    
    var isQuizFinished: Bool = false
    
    func startQuiz() {
        quiz.shuffle(questions: true, options: true)
    }
    
    func nextQuestion() {
        
        if currentQuestionIndex == quiz.questionsCount - 1 {
            isQuizFinished = true
        }
        
        if currentQuestionIndex < quiz.questionsCount - 1 {
            currentQuestionIndex += 1
            isQuestionAnswered = false
        }
    }
}
