//
//  QuizService.swift
//  QuizAI
//
//  Created by Oleh Zimin on 09.07.2025.
//

import Foundation

@Observable
class QuizService {
    static let shared: QuizService = QuizService()
    
    private init() { }
    
    private var cachedQuiz: QuizModel? = nil
    private(set) var generationPhase: QuizGenerationPhase = .idle
    private(set) var alertMessage: String? = nil
    
    func generateQuiz(name: String, set: String? = nil, tags: [String], icon: String, color: String,
                      difficulty: QuizDifficulty, detailedTopic: String, questionsCount: Int, types: [QuestionType]) {
        generationPhase = .generating
        
        let topic = [name, detailedTopic].joined(separator: ". ")
        
        Task {
            do {
                let questions = try await OpenAIUtility.generateQuestions(
                    topic: topic,
                    questionsCount: questionsCount,
                    types: types,
                    difficulty: difficulty
                )
                
                cachedQuiz = QuizModel(
                    name: name,
                    set: set,
                    tags: tags,
                    icon: icon,
                    color: color,
                    difficulty: difficulty,
                    questions: questions
                )
            } catch let error as OpenAIResponseError {
                alertMessage = error.localizedDescription
                print(error)
            } catch let error as URLError where error.code == .timedOut {
                alertMessage = "The request took too long. Please check your connection and try again."
                print(error)
            } catch let error as URLError where error.code == .badServerResponse {
                alertMessage = "Invalid server response. Please try again."
                print(error)
            } catch {
                alertMessage = error.localizedDescription
                print(error)
            }
            
            generationPhase = .finished
        }
    }
    
    func getLastGeneratedQuiz() throws -> QuizModel {
        guard let newQuiz = cachedQuiz else { throw QuizManagerError.emptyCache }
        
        cachedQuiz = nil
        generationPhase = .idle
        
        return newQuiz
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
