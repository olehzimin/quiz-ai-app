//
//  QuizRowView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import SwiftUI

struct QuizRowView: View {
    let quiz: Quiz
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(.background)
                .shadow(color: Color(white: 0.8), radius: 14)
            
//            ProgressBarView(color: Color(activity.colorName), progress: progress)
//                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            HStack(spacing: 0) {
                Image(systemName: quiz.icon)
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(Color.cyan)
                    .font(.title.weight(.light))
                    .frame(width: 70)
                    .frame(maxHeight: .infinity)
                
                VStack(alignment: .leading) {
                    Text(quiz.name)
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text(quiz.category)
                            .font(.callout)
                            .foregroundStyle(.gray)
                        
                        Text(quiz.difficulty)
                            .font(.callout)
                            .foregroundStyle(.red)
                        
//                        Text("\(quiz.questionsCount)")
//                            .foregroundStyle(.gray)
                        
//                        Text("-25")
//                            .font(.callout)
//                            .foregroundStyle(.gray)
                    }
                    
                    
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("100")
                        .font(.title2).bold()
                        .foregroundStyle(Color.cyan)
                        
//                    Rectangle()
//                        .frame(height: 1)
//                        .padding(.horizontal)
                    
                    Text("100")
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(height: 80)
    }
}

#Preview {
    if let quiz = Quiz.mock {
        QuizRowView(quiz: quiz)
            .padding()
    }
}
