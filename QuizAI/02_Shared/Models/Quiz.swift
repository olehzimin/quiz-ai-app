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
    private(set) var questions: [Question]
    
    var completedQuestionsCount: Int = 0
    
    // Cached properties, must be updated whenever questions changed
    var questionsCount: Int = 0
    var questionsTypeCounts: [QuestionType: Int] = [:]
    
    init(name: String, set: String? = nil, tags: [String], icon: String, color: String, difficulty: QuizDifficulty, questions: [Question]) {
        self.name = name
        self.set = set
        self.tags = tags
        self.icon = icon
        self.color = color
        self.difficulty = difficulty
        self.questions = questions
        
        updateCache()
    }
}

extension Quiz {
    var completedPercent: Int {
        completedQuestionsCount * 100 / questionsCount
    }
    
    func updateQuestions(with newQuestions: [Question]) {
        questions = newQuestions
        
        updateCache()
    }
    
    private func updateCache() {
        // Update questions count
        questionsCount = questions.count
        
        // Update questions type count
        var counts: [QuestionType: Int] = [
            .flashcard: 0,
            .multichoice: 0,
            .trueFalse: 0
        ]
        for question in questions {
            counts[question.type, default: 0] += 1
        }
        questionsTypeCounts = counts
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


