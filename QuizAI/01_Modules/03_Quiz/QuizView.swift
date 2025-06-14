//
//  QuizView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 13.06.2025.
//

import SwiftUI

struct QuizView: View {
    let quiz: Quiz
    
    var body: some View {
        Text("Welocme to quiz \(quiz.name)")
    }
}

#Preview {
    if let quiz = Quiz.mock {
        QuizView(quiz: quiz)
    }
}
