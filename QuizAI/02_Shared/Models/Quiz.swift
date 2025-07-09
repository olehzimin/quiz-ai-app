//
//  Quiz.swift
//  QuizAI
//
//  Created by Oleh Zimin on 15.06.2025.
//

import Foundation
import SwiftData

enum QuizDifficulty: String, Codable, CaseIterable {
    case easy, medium, hard
}

@Model
class Quiz {
    var name: String
    var set: String?
    var tags: [String]
    var icon: String
    var color: String
    var difficulty: QuizDifficulty
    var questions: [Question]
    var completedQuestionsCount: Int = 0
    
    
//    private var questionsTypeCount: [QuestionType: Int]? = nil
    
    init(name: String, set: String? = nil, tags: [String], icon: String, color: String, difficulty: QuizDifficulty, questions: [Question]) {
        self.name = name
        self.set = set
        self.tags = tags
        self.icon = icon
        self.color = color
        self.difficulty = difficulty
        self.questions = questions
    }
}

extension Quiz {
    var questionsCount: Int {
        questions.count
    }
    var completedPercent: Int {
        completedQuestionsCount * 100 / questionsCount
    }
    
    // MARK: Rework
    // Rework logic of question type count
    var questionsTypeCount: [QuestionType: Int] {
        var typeCount: [QuestionType: Int] = [
            .flashcard: 0,
            .multichoice: 0,
            .trueFalse: 0
        ]
        
        questions.forEach { question in
            switch question.type {
            case .flashcard:
                typeCount[.flashcard]! += 1
            case .multichoice:
                typeCount[.multichoice]! += 1
            case .trueFalse:
                typeCount[.trueFalse]! += 1
            }
        }
        
        return typeCount
    }
}

extension Quiz {
    static var mockQuestions: [Question]? {
        var questions: [Question] = []
        guard let url = Bundle.main.url(forResource: "QuestionsSample.json", withExtension: nil) else {
            print("URL error")
            return nil
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("Data error")
            return nil
        }
        
        if let decodedQuestions = try? JSONDecoder().decode([Question].self, from: data) {
            questions = decodedQuestions
        }
        
        return questions
    }
    
    static var mock: Quiz? {
        if let questions = Self.mockQuestions {
            let newQuiz = Quiz(
                name: "Sample Quiz",
                set: nil,
                tags: ["General", "Quiz", "Sample"],
                icon: "sun.max",
                color: "greenQuiz",
                difficulty: .medium,
                questions: questions)
            
            return newQuiz
        }
        
        return nil
    }
}


