//
//  HeaderQuizView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 11.07.2025.
//

import SwiftUI

struct HeaderQuizView: View {
    let viewModel: QuizViewModel
    
    var timer: Bool = true
    
    var body: some View {
        Text("\(viewModel.currentQuestionIndex + 1) / \(viewModel.quiz.questionsCount)")
        
        if timer {
            Text("timer")
        }
    }
}

#Preview {
    if let quiz = Quiz.mock {
        HeaderQuizView(viewModel: QuizViewModel(quiz: quiz))
    }
}
