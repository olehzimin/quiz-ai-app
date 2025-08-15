//
//  QuestionModel.swift
//  QuizAI
//
//  Created by Oleh Zimin on 17.06.2025.
//

import Foundation
import SwiftData

struct QuestionModel: Identifiable {
    var id: UUID = UUID()
    var type: QuestionType
    var question: String
    var options: [QuestionOption]
    var explanation: String
    var isCompleted: Bool
}

extension QuestionModel: Codable {
    enum CodingKeys: String, CodingKey {
        case type, question, options, explanation, isCompleted
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(QuestionType.self, forKey: .type)
        let question = try container.decode(String.self, forKey: .question)
        let options = try container.decode([QuestionOption].self, forKey: .options)
        let explanation = try container.decode(String.self, forKey: .explanation)
        let isCompleted: Bool = (try? container.decode(Bool.self, forKey: .isCompleted)) ?? false
        
        self.init(
            type: type,
            question: question,
            options: options,
            explanation: explanation,
            isCompleted: isCompleted
        )
    }
}

enum QuestionType: String, Codable {
    case flashcard, multichoice, trueFalse
}

struct QuestionOption: Codable {
    var text: String
    var isCorrect: Bool
}
