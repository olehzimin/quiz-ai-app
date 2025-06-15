//
//  Quiz.swift
//  QuizAI
//
//  Created by Oleh Zimin on 15.06.2025.
//

import Foundation
import SwiftData

@Model
class Quiz {
    var name: String
    var set: String?
    var tags: [String]
    var icon: String
    var color: String
    var difficulty: String
    var questions: [Question]
    
    init(name: String, set: String? = nil, tags: [String], icon: String, color: String, difficulty: String, questions: [Question]) {
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
                color: "green",
                difficulty: "Medium",
                questions: questions)
            
            return newQuiz
        }
        
        return nil
    }
}
