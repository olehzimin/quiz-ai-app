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
    
    func set(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createQuiz(name: String, set: String? = nil, tags: [String],
                    icon: String, color: String, difficulty: QuizDifficulty,
                    detailedTopic: String, questionsCount: Int, types: [QuestionType]) {
        alertMessage = nil
        
        let topic = [name, detailedTopic].joined(separator: ". ")
        let newQuiz = QuizModel(
            name: name,
            set: set,
            tags: tags,
            icon: icon,
            color: color,
            difficulty: difficulty,
            questions: []
        )
        modelContext?.insert(newQuiz)
        
        newQuiz.generationPhase = .generating
        Task {
            if let questions = await generateQuestions(
                topic: topic,
                questionsCount: questionsCount,
                types: types,
                difficulty: difficulty
            ) {
                newQuiz.resetQuestions(with: questions)
            } else {
                modelContext?.delete(newQuiz)
            }
            newQuiz.generationPhase = .finished
        }
    }
    
    func rewriteQuiz(_ quiz: QuizModel, name: String, set: String? = nil,
                     tags: [String], icon: String, color: String) {
        quiz.name = name
        quiz.set = set
        quiz.tags = tags
        quiz.icon = icon
        quiz.color = color
    }
    
    func regenerateQuestions(in quiz: QuizModel, detailedTopic: String, questionsCount: Int,
                             types: [QuestionType], difficulty: QuizDifficulty) {
        let topic = [quiz.name, detailedTopic].joined(separator: ". ")
        
        quiz.generationPhase = .generating
        Task {
            if let questions = await generateQuestions(
                topic: topic,
                questionsCount: questionsCount,
                types: types,
                difficulty: difficulty
            ) {
                quiz.resetQuestions(with: questions)
            }
            quiz.generationPhase = .finished
        }
    }
    
    func addQuestions(in quiz: QuizModel, detailedTopic: String, questionsCount: Int,
                      types: [QuestionType], difficulty: QuizDifficulty) {
        var questions = quiz.questions
        let topic = [quiz.name, detailedTopic].joined(separator: ". ")
        
        quiz.generationPhase = .generating
        Task {
            if let newQuestions = await generateQuestions(
                topic: topic,
                questionsCount: questionsCount,
                types: types,
                difficulty: difficulty
            ) {
                questions += newQuestions
                quiz.resetQuestions(with: questions)
            }
            quiz.generationPhase = .finished
        }
    }
    
    private func generateQuestions(topic: String, questionsCount: Int,
                                   types: [QuestionType], difficulty: QuizDifficulty) async -> [QuestionModel]? {
        var questions: [QuestionModel]? = nil
        
        generationPhase = .generating
        do {
            questions = try await OpenAIUtility.generateQuestions(
                topic: topic,
                questionsCount: questionsCount,
                types: types,
                difficulty: difficulty
            )
        } catch {
            handle(error)
        }
        generationPhase = .finished
        
        return questions
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

enum QuizGenerationPhase: Codable {
    case idle
    case generating
    case finished
}
