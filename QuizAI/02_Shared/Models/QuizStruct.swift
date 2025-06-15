//
//  Quiz.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import Foundation

//struct QuizSet: Identifiable, Codable {
//    let id: UUID = UUID()
//    let name: String
//    let quizes: [Quiz]
//}

struct QuizStruct: Identifiable, Codable {
    let id: UUID = UUID()
    let name: String
    let set: String?
    let tags: [String]
    let icon: String
    let color: String
    let difficulty: String
    let questions: [Question]
}

struct Question: Identifiable, Codable {
    let id: UUID = UUID()
    let type: QuestionType
    var completed: Bool?
    let question: String
    let options: [String]
    let answerIndex: Int
    let explanation: String?
}

enum QuestionType: String, Codable {
    case flashcard, multiChoice, trueFalse
}

extension Quiz {
    var questionsCount: Int {
        questions.count
    }
    var completedQuestionsCount: Int {
        questions.filter { $0.completed == true }.count
    }
    var completedPercent: Int {
        completedQuestionsCount * 100 / questionsCount
    }
    
    // MARK: Optimization
    // Computed every time. Maybe better to make a lazy stored property?
    var questionsTypeCount: [QuestionType: Int] {
        var typeCount: [QuestionType: Int] = [
            .flashcard: 0,
            .multiChoice: 0,
            .trueFalse: 0
        ]
        
        questions.forEach { question in
            switch question.type {
            case .flashcard:
                typeCount[.flashcard]! += 1
            case .multiChoice:
                typeCount[.multiChoice]! += 1
            case .trueFalse:
                typeCount[.trueFalse]! += 1
            }
        }
        
        return typeCount
    }
}


//
//extension Quiz: Hashable {
//    static func == (lhs: Quiz, rhs: Quiz) -> Bool {
//        lhs.id == rhs.id
//    }
//    
//    func hash(into hasher: inout Hasher) {
//            hasher.combine(id)
//        }
//}
