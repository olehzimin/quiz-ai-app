//
//  QuizService.swift
//  QuizAI
//
//  Created by Oleh Zimin on 09.07.2025.
//

import SwiftUI
import SwiftData

@Observable
class QuizService {
    static let shared: QuizService = QuizService()
    
    private init() { }
    
    private var modelContext: ModelContext? = nil
    private(set) var generationPhase: QuizGenerationPhase = .idle
    private(set) var alertMessage: String? = nil
    
    func createQuiz(name: String, set: String? = nil, tags: [String],
                    icon: String, color: String, difficulty: QuizDifficulty,
                    detailedTopic: String, questionsCount: Int, types: [QuestionType],
                    using modelContext: ModelContext) {
        self.modelContext = modelContext
        
        let newQuiz = QuizModel(
            name: name,
            set: set,
            tags: tags,
            icon: icon,
            color: color,
            difficulty: difficulty,
            questions: []
        )
        modelContext.insert(newQuiz)
        
        generationPhase = .generating
        Task {
            do {
                let topic = [name, detailedTopic].joined(separator: ". ")
                let questions = try await OpenAIUtility.generateQuestions(
                    topic: topic,
                    questionsCount: questionsCount,
                    types: types,
                    difficulty: difficulty
                )
                
                newQuiz.resetQuestions(with: questions)
            } catch {
                modelContext.delete(newQuiz)
                handle(error)
            }
            generationPhase = .finished
        }
    }
    
    private func handle(_ error: Error) {
        print(error)
        switch error {
        case let error as OpenAIResponseError:
            alertMessage = error.localizedDescription
        case let error as URLError where error.code == .timedOut:
            alertMessage = "The request took too long. Please check your connection and try again."
        case let error as URLError where error.code == .badServerResponse:
            alertMessage = "Invalid server response. Please try again."
        default:
            alertMessage = error.localizedDescription
        }
    }
}

enum QuizManagerError: Error {
    case emptyCache
}

enum QuizGenerationPhase {
    case idle
    case generating
    case finished
}
