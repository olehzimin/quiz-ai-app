//
//  QuizModel.swift
//  QuizAI
//
//  Created by Oleh Zimin on 15.06.2025.
//

import SwiftUI
import SwiftData

@Model
final class QuizModel: Identifiable {
    var id: UUID
    var name: String
    var set: String?
    var tags: [String]
    var icon: String
    var color: String
    var difficulty: QuizDifficulty
    var questions: [QuestionModel]
    
    // Cached properties, must be updated whenever questions change
    private(set) var questionsCount: Int = 0
    private(set) var questionsTypeCounts: [QuestionType: Int] = [:]
    private(set) var completedQuestionsCount: Int = 0
    
    init(name: String, set: String? = nil, tags: [String], icon: String, color: String, difficulty: QuizDifficulty, questions: [QuestionModel]) {
        self.id = UUID()
        self.name = name
        self.set = set
        self.tags = tags
        self.icon = icon
        self.color = color
        self.difficulty = difficulty
        self.questions = questions
        
        updateCache()
    }
}

extension QuizModel {
    var completedPercent: Int {
        completedQuestionsCount * 100 / questionsCount
    }
    
    func resetQuestions(with newQuestions: [QuestionModel]) {
        questions = newQuestions
        
        updateCache()
    }
    
    private func updateCache() {
        updateQuestionsCount()
        updateQuestionsTypeCounts()
        updateCompletedQuestionsCount()
    }
    
    private func updateQuestionsCount() {
        questionsCount = questions.count
    }
    
    private func updateQuestionsTypeCounts() {
        var counts: [QuestionType: Int] = [
            .flashcard: 0,
            .multichoice: 0,
            .trueFalse: 0
        ]
        for question in questions {
            counts[question.type, default: 0] += 1
        }
        questionsTypeCounts = counts
    }
    
    private func updateCompletedQuestionsCount() {
        let completed = questions.filter { $0.isCompleted == true }
        completedQuestionsCount = completed.count
    }
}

extension QuizModel {
    static func mockQuestions() throws -> [QuestionModel] {
        var questions: [QuestionModel] = []
        
        guard let url = Bundle.main.url(forResource: "QuestionsSample.json", withExtension: nil) else { throw URLError(.badURL) }
        let data = try Data(contentsOf: url)
        questions = try JSONDecoder().decode([QuestionModel].self, from: data)
        
        return questions
    }
    
    static func mockQuiz() -> QuizModel {
        var newQuiz = QuizModel(
            name: "Sample Quiz",
            set: nil,
            tags: ["General", "Quiz", "Sample"],
            icon: "sun.max",
            color: "greenQuiz",
            difficulty: .medium,
            questions: [])
        
        do {
            newQuiz.questions = try Self.mockQuestions()
        } catch {
            print(error)
        }
        
        return newQuiz
    }
}

enum QuizDifficulty: String, Codable, CaseIterable {
    case easy, medium, hard
}
