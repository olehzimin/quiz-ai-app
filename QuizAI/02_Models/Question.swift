//
//  Question.swift
//  QuizAI
//
//  Created by Oleh Zimin on 17.06.2025.
//

import Foundation
import SwiftData

enum QuestionType: String, Codable {
    case flashcard, multichoice, trueFalse
}

@Model
final class Question: Identifiable {
    var id: UUID = UUID()
    var type: QuestionType
    var question: String
    var options: [String]
    var answerIndex: Int?
    var explanation: String
    
    // Cached properties
    var completed: Bool = false
    
    init(type: QuestionType, question: String, options: [String], answerIndex: Int? = nil, explanation: String) {
        self.type = type
        self.question = question
        self.options = options
        self.answerIndex = answerIndex
        self.explanation = explanation
    }
    
    func shuffleOptions() {
        guard type == .multichoice, let answerIndex = answerIndex else { return }

        let correctAnswer = options[answerIndex]
        options.shuffle()
        self.answerIndex = options.firstIndex(of: correctAnswer)
    }
}

extension Question: Decodable {
    enum CodingKeys: String, CodingKey {
        case type, question, options, answerIndex, explanation
    }
    
    convenience init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(QuestionType.self, forKey: .type)
        let question = try container.decode(String.self, forKey: .question)
        let options = try container.decode([String].self, forKey: .options)
        let answerIndex = try container.decodeIfPresent(Int.self, forKey: .answerIndex)
        let explanation = try container.decode(String.self, forKey: .explanation)
        
        self.init(
            type: type,
            question: question,
            options: options,
            answerIndex: answerIndex,
            explanation: explanation
        )
    }
}

