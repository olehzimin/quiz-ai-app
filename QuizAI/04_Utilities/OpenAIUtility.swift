//
//  OpenAIUtility.swift
//  QuizAI
//
//  Created by Oleh Zimin on 17.06.2025.
//

import Foundation

struct OpenAIUtility {
    private init() { }
    
    static private let apiURL: URL? = URL(string: "https://api.openai.com/v1/chat/completions")
    static private let model = "gpt-4.1-mini"
    
    static func generateQuestions(
        topic: String, questionsCount: Int,
        types: [QuestionType], difficulty: QuizDifficulty) async throws -> [QuestionModel] {
        let systemMessage = Message.system()
        let userMessage = Message.user(
            topic: topic, questionsCount: questionsCount,
            types: types, difficulty: difficulty
        )
        
        let urlRequest = try urlRequest(systemMessage: systemMessage, userMessage: userMessage)
        let questions = try await fetchQuestions(using: urlRequest)
        
        return questions
    }
    
    static private func urlRequest(systemMessage: Message, userMessage: Message) throws -> URLRequest {
        let openAIRequestBody = OpenAIRequestBody(model: model, messages: [systemMessage, userMessage])
        
        guard let apiURL else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Secrets.openAIKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(openAIRequestBody)
        
        return request
    }
    
    static private func fetchQuestions(using request: URLRequest) async throws -> [QuestionModel] {
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
        let questions = try JSONDecoder().decode([QuestionModel].self, from: questionsData)
        
        return questions
    }
    
    static private func handleURLResponse(_ response: URLResponse) throws {
        
    }
}

struct Message: Codable {
    let role: String
    let content: String
}

struct OpenAIRequestBody: Codable {
    let model: String
    let messages: [Message]
}

struct OpenAIResponseBody: Decodable {
    let choices: [Choice]
    
    struct Choice: Decodable {
        let message: Message
    }
}

// MARK: Prompts
extension Message {
    static func system() -> Message {
        Message(
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
                            "options": ["Option A", "Option B", "Option C", "Option D"], // For flashcards make 2 options: ["repeat", "know"] and for trueFalse: ["false", "true"] .
                            "answerIndex": 0, // Index in the options array (for flashcards always index of "know" option).
                            "explanation": "Explanation or context." // Brief explanation for "multichoice", "trueFalse and more deep for "flashcard". 
                          },
                          ...
                        ]
                        
                        # Rules
                        - Only use the types: "flashcard", "multichoice", or "trueFalse".
                        - For "flashcard", asign index of "know" option to the "answerIndex".
                        - All questions must be relevant, clear, and match the requested topic and difficulty.
                        - Consider that difficulty levels are only 3: "easy", "medium", "hard".
                        - Provide a balanced mix of question types if multiple are requested.
                        - Do not include any extra text, only return valid JSON.
                        """
        )
    }
    
    static func user(
        topic: String, questionsCount: Int,
        types: [QuestionType], difficulty: QuizDifficulty) -> Message {
        let stringTypes = types.map { $0.rawValue }.joined(separator: ", ")
        
        return Message(
            role: "user",
            content:
                """
                Topic: \(topic).
                Number of questions: \(questionsCount).
                Use only the following question types: \(stringTypes).
                Difficulty: \(difficulty.rawValue).
                Follow the required JSON format and rules provided.
                """
        )
    }
}

// MARK: Errors
enum OpenAIResponseError: Error, LocalizedError {
    case missingContent
    case encodingFailed
    
    case needsClarification
    
    private var errorDescription: String {
        switch self {
        case .missingContent:
            "The server response is missing the expected message content."
        case .encodingFailed:
            "Encoding of content failed."
        case .needsClarification:
            "Topic was not clear enough. Try giving a more detailed subject."
        }
    }
}
