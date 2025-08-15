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
        try handleURLResponse(response)
        
        // Decode recieved data from OpenAI
        let openAIResponseBody = try JSONDecoder().decode(OpenAIResponseBody.self, from: data)
        
        guard let jsonString = openAIResponseBody.choices.first?.message.content else {
            throw OpenAIResponseError.missingContent
        }
        guard let contentData = jsonString.data(using: .utf8) else {
            throw OpenAIResponseError.encodingFailed
        }
        
        // Decode recieved content data
        let content = try JSONDecoder().decode(OpenAIResponseContent.self, from: contentData)
        try handleContentStatus(content.status)
        
        return content.questions
    }
    
    static private func handleURLResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200...299).contains(httpResponse.statusCode) else { throw URLError(.badServerResponse) }
    }
    
    static private func handleContentStatus(_ status: ContentStatus) throws {
        switch status {
        case .ok:
            print(status.message)
            return
        default:
            throw OpenAIResponseError.badStatus(message: status.message)
        }
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

struct OpenAIResponseContent: Decodable {
    let status: ContentStatus
    let questions: [QuestionModel]
}

enum ContentStatus: String, Codable {
    case ok
    case needsClarification
    case generationFailed
    
    var message: String {
        switch self {
        case .ok:
            "Everything looks good. Your quiz is ready!"
        case .needsClarification:
            "The topic is unclear. Try making your topic more specific."
        case .generationFailed:
            "Something went wrong while creating your quiz. Please try again."
        }
    }
}

// MARK: Prompts
extension Message {
    static func system() -> Message {
        Message(
            role: "system",
                content:
                """
                You are a quiz generator. Generate a quiz based on a user-provided topic,
                desired question types, difficulty level, and number of questions.
                
                # Output Format
                Return a single JSON object with this exact shape:
                
                {
                    "status": "ok" | "needsClarification" | "generationFaild",
                    "questions": [] | [
                        {
                            "type": "flashcard" | "multichoice" | "trueFalse",
                            "question": "Question text here.",
                            "options": [
                                { "text": "Option A", "isCorrect": false },
                                { "text": "Option B", "isCorrect": true },
                                ...
                            ],
                            "explanation": "Explanation or context."
                        },
                        ...
                    ]
                }
                
                # Status Rules
                - If the request is valid, set "status": "ok" and return the questions array.
                - If the topic is unclear, set "status": "needsClarification" and set "questions": [].
                - If you cannot generate questions for some rare reason (e.g., internal failure or 
                  request is inappropriate), set "status": "generationFailed" and set "questions": [].

                # Question Rules (apply only when status = "ok")
                - Only use the types: "flashcard", "multichoice", or "trueFalse".
                - For "flashcard": must be exactly 2 options:
                  [{ "text": "repeat", "isCorrect": false }, { "text": "know", "isCorrect": true }]
                - For "trueFalse": must be exactly 2 options:
                  [{ "text": "false", "isCorrect": true|false }, { "text": "true", "isCorrect": true|false }]
                  and exactly one of them must have "isCorrect": true, depending on question logic.
                - For "multichoice": must be 4 options, include exactly one correct answer, others must be false.
                - Match requested topic, difficulty (could be only 3 levels "easy", "medium", "hard"), and types.
                - Number of questions must match the request.
                - Explanation: brief for multichoice/trueFalse; deeper for flashcard.
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
    case badStatus(message: String)
    
    private var errorDescription: String {
        switch self {
        case .missingContent:
            "The server response is missing the expected message content."
        case .encodingFailed:
            "Encoding of content failed."
        case .badStatus(let message):
            message
        }
    }
}
