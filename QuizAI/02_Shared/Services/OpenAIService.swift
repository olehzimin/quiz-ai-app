//
//  OpenAIService.swift
//  QuizAI
//
//  Created by Oleh Zimin on 17.06.2025.
//

import Foundation

struct OpenAIService {
    private init() {}
    
    static private let apiURL: URL? = URL(string: "https://api.openai.com/v1/chat/completions")
    static private let model = "gpt-4.1-mini"
    
    static private let systemMessage = Message(
        role: "system",
        content:
            """
            You are a quiz generator. Generate a quiz based on a user-provided topic, desired question types, difficulty level, and number of questions.

            # Output Format
            Return an array of question objects in this exact JSON format:

            [
              {
                "type": "flashcard" | "multichoice" | "trueFalse",
                "question": "Question text here.",
                "options": ["Option A", "Option B", "Option C", "Option D"], // Leave empty for flashcards and make 2 options for trueFalse.
                "answerIndex": 0, // Index in the options array (omit for flashcards).
                "explanation": "Explanation or context." // Brief explanation for "multichoice", "trueFalse and more deep for "flashcard". 
              },
              ...
            ]

            # Rules
            - Only use the types: "flashcard", "multichoice", or "trueFalse".
            - For "flashcard", leave "options" empty and omit "answerIndex".
            - All questions must be relevant, clear, and match the requested topic and difficulty.
            - Consider that difficulty levels are only 3: "easy", "medium", "hard".
            - Provide a balanced mix of question types if multiple are requested.
            - Do not include any extra text, only return valid JSON.
            """
    )
    
    static private func userMessage(topic: String, questionCount: Int, types: [QuestionType], difficulty: QuizDifficulty) -> Message {
        let stringTypes = types.map { $0.rawValue }.joined(separator: ", ")
        
        return Message(
            role: "user",
            content:
                """
                Topic: \(topic).
                Number of questions: \(questionCount).
                Use only the following question types: \(stringTypes).
                Difficulty: \(difficulty.rawValue).
                Follow the required JSON format and rules provided.
                """
        )
    }
    
    static func generateQuiz(topic: String, questionCount: Int, types: [QuestionType], difficulty: QuizDifficulty) async throws -> [Question] {
        let userMassage = userMessage(topic: topic, questionCount: questionCount, types: types, difficulty: difficulty)
        let openAIRequestBody = OpenAIRequestBody(model: model, messages: [systemMessage, userMassage])
        
        guard let apiURL else {
            throw URLError(.badURL)
        }
        
        // Set the URLRequest
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Secrets.openAIKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(openAIRequestBody)
        
        // Fetch from OpenAI
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Decode recieved data from OpenAI
        let openAIResponseBody = try JSONDecoder().decode(OpenAIResponseBody.self, from: data)
        
        guard let jsonString = openAIResponseBody.choices.first?.message.content else {
            throw OpenAIResponseError.missingContent
        }
        guard let questionsData = jsonString.data(using: .utf8) else {
            throw OpenAIResponseError.encodingFailed
        }
        
        // Decode recieved questions data
        let questions = try JSONDecoder().decode([Question].self, from: questionsData)
        
        return questions
    }
}

struct OpenAIRequestBody: Codable {
    let model: String
    let messages: [Message]
}

struct Message: Codable {
    let role: String
    let content: String
}

struct OpenAIResponseBody: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: Message
    }
}

enum OpenAIResponseError: Error {
    case missingContent
    case encodingFailed
}

extension OpenAIResponseError: LocalizedError {
    var errorDescription: String {
        switch self {
        case .missingContent:
            "The server response is missing the expected message content."
        case .encodingFailed:
            "Encoding of content failed"
        }
    }
}
