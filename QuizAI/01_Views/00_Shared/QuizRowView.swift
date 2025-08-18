//
//  QuizRowView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import SwiftUI

struct QuizRowView: View {
    let quiz: QuizModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.background)
                .shadow(color: Color(white: 0.8), radius: 14)
            
            HStack(spacing: 0) {
                Image(systemName: quiz.icon)
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(Color(quiz.color))
                    .font(.title.weight(.light))
                    .frame(width: 70)
                    .frame(maxHeight: .infinity)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(quiz.name)
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 16) {
                        if let set = quiz.set {
                            Text(set)
                                .font(.callout)
                                .foregroundStyle(.gray)
                        }
                        
                        Text(quiz.difficulty.rawValue)
                            .font(.callout)
                            .foregroundStyle(.red)
                    }
                    
                    
                }
                
                Spacer()
                
                if quiz.isReady {
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("\(quiz.completedQuestionsCount)")
                            .font(.title2).bold()
                            .foregroundStyle(Color(quiz.color))
                        
                        Text("\(quiz.questionsCount)")
                            .font(.callout)
                            .foregroundStyle(.gray)
                    }
                    .padding(.horizontal)
                } else {
                    HStack {
                        ProgressView()
                            .font(.title2)
                    }
                    .padding(.horizontal)
                }
            }
        }
        .frame(height: 80)
        .opacity(quiz.isReady ? 1 : 0.6)
    }
}

#Preview {
    let quiz = QuizModel.mockQuiz()
    
    return
    QuizRowView(quiz: quiz)
        .padding()
}
