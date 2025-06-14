//
//  HomeView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import SwiftUI

struct HomeView: View {
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
                                QuizStartView(quiz: quiz)
                                    .presentationDetents([.large])
                                    .presentationDragIndicator(.visible)
                            }
                    }
                }
                .padding()
            }
            
            .onAppear {
                loadQuizes()
            }
            
            AddButtonView {
                loadQuizes()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
        .navigationTitle("Challenge yourself")
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}

extension HomeView {
    func loadQuizes() {
        if let quiz = Quiz.mock {
            quizes.append(quiz)
        }
    }
}
