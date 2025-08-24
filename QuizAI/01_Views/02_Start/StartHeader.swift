//
//  StartHeader.swift
//  QuizAI
//
//  Created by Oleh Zimin on 24.08.2025.
//

import SwiftUI

struct StartHeader: View {
    let quiz: QuizModel
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(GameService.self) private var gameService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showsDeleteAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                Text(quiz.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title).bold()
                
                Text("\(quiz.completedPercent)%")
                    .font(.title).bold()
                    .foregroundStyle(Color(quiz.color))
            }
            .frame(height: 70, alignment: .top)
            
            HStack(spacing: 16) {
                if let set = quiz.set {
                    Text(set)
                        .bold()
                }
                
                Text(quiz.difficulty.rawValue)
                    .foregroundStyle(.red)
                
                Text("\(quiz.questionsCount) tasks")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                ForEach(quiz.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            Color(quiz.color)
                .brightness(0.6)
                .ignoresSafeArea()
        )
        .safeAreaInset(edge: .top) {
            navigationBarView
        }
        .alert("Are you sure you want to delete?", isPresented: $showsDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(quiz)
                dismiss()
            }
            
            Button("Cancel", role: .cancel) { }
        }
    }
}

extension StartHeader {
    private var navigationBarView: some View {
        HStack(spacing: 32) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
            
            Spacer()
            
            Button {
                showsDeleteAlert = true
            } label: {
                Image(systemName: "trash")
            }
            .foregroundStyle(.red)
            
            Button {
                dismiss()
                navigationService.path.append(Route.edit(quiz: quiz))
            } label: {
                Image(systemName: "pencil")
            }
        }
        .font(.title2)
        .padding(.horizontal)
        .padding(.top, 32)
        .foregroundStyle(.black)
        
    }
}
