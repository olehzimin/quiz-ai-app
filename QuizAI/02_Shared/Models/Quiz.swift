//
//  Quiz.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import Foundation

struct Quiz: Identifiable, Codable {
    let id: UUID = UUID()
    let name: String
    let category: String
    let icon: String
    let difficulty: String
    let questions: [Question]
}

struct Question: Identifiable, Codable {
    let id: UUID = UUID()
    let type: QuestionType
    var completed: Bool?
    let question: String
    let options: [String]?
    let answerIndex: Int?
    let explanation: String?
}

enum QuestionType: String, Codable {
    case flashcard
    case trueFalse
    case multipleChoice
}

extension Quiz {
    var questionsCount: Int {
        questions.count
    }
    var completedQuestionsCount: Int {
        var count = 0
        questions.forEach {
            if $0.completed == true {
                count += 1
            }
        }
        
        return count
    }
}

extension Quiz {
    static var mock: Quiz? {
        guard let url = Bundle.main.url(forResource: "QuizSample.json", withExtension: nil) else {
            print("URL error")
            return nil
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("Data error")
            return nil
        }
        
        if let quiz = try? JSONDecoder().decode(Quiz.self, from: data) {
            return quiz
        }
        
        return nil
    }
}
