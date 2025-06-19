//
//  Question.swift
//  QuizAI
//
//  Created by Oleh Zimin on 17.06.2025.
//

import Foundation

enum QuestionType: String, Codable {
    case flashcard, multichoice, trueFalse
}

struct Question: Codable {
    let type: QuestionType
    let question: String
    let options: [String]
    let answerIndex: Int?
    let explanation: String
}


