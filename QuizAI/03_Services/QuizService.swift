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
    private(set) var isGenerating: Bool = false
    
    func generateQuiz(name: String, set: String? = nil, tags: [String], icon: String, color: String,
                      difficulty: QuizDifficulty, detailedTopic: String, questionsCount: Int, types: [QuestionType]) {
        isGenerating = true
        
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
                
                isGenerating = false
                print(questions)
            } catch {
                print(error)
            }
        }
    }
    
    func getLastGeneratedQuiz() throws -> QuizModel {
        if let newQuiz = cachedQuiz {
            cachedQuiz = nil
            return newQuiz
        } else {
            throw QuizManagerError.emptyCache
        }
    }
}

enum QuizManagerError: Error {
    case emptyCache
}
