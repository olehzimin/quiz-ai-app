//
//  HomeView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import SwiftUI

struct HomeView: View {
    @Binding var path: NavigationPath
    @State private var quizes: [Quiz] = []
    @State private var showStartSheet: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack {
                    ForEach(quizes) { quiz in
                        QuizRowView(quiz: quiz)
                            .onTapGesture {
                                showStartSheet = true
                            }
                            .sheet(isPresented: $showStartSheet) {
                                QuizStartView(quiz: quiz, path: $path)
                                    .presentationDetents([.fraction(0.98)])
                                    .presentationDragIndicator(.visible)
                            }
                            
                    }
                }
                .padding()
            }
            
            AddButtonView {
                loadQuizes()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
        .navigationDestination(for: Quiz.self) { quiz in
                QuizView(quiz: quiz, path: $path)
        }
        .navigationTitle("Challenge yourself")
    }
}

#Preview {
    NavigationStack {
        HomeView(path: .constant(NavigationPath()))
    }
}

extension HomeView {
    func loadQuizes() {
        if let quiz = Quiz.mock {
            quizes.append(quiz)
        }
    }
}
