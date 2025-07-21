//
//  Quiz.swift
//  QuizAI
//
//  Created by Oleh Zimin on 15.06.2025.
//

import SwiftUI
import SwiftData

enum QuizDifficulty: String, Codable, CaseIterable {
    case easy, medium, hard
}

@Model
class Quiz: Identifiable {
    var id: UUID
    var name: String
    var set: String?
    var tags: [String]
    var icon: String
    var color: String
    var difficulty: QuizDifficulty
    @Relationship(deleteRule: .cascade) var questions: [Question]
    
    // Cached properties, must be updated whenever questions changed
    private(set) var questionsCount: Int = 0
    private(set) var questionsTypeCounts: [QuestionType: Int] = [:]
    private(set) var completedQuestionsCount: Int = 0
    
    init(name: String, set: String? = nil, tags: [String], icon: String, color: String, difficulty: QuizDifficulty, questions: [Question]) {
        self.id = UUID()
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
    
    func shuffle(questions: Bool, options: Bool) {
        self.tags.shuffle()
        print("tags shuffled")
//        if questions {
//            self.questions.shuffle()
//        }
//        
//        if options {
//            for index in self.questions.indices {
//                self.questions[index].shuffleOptions()
//            }
//        }
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
    
    func updateCompletedQuestions() {
        let completed = questions.filter { $0.completed == true }
        
        completedQuestionsCount = completed.count
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


