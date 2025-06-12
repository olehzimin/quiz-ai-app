//
//  HomeView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import SwiftUI

struct HomeView: View {
    @State private var quizes: [Quiz] = []
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(quizes) { quiz in
                    QuizRowView(quiz: quiz)
                }
            }
            .padding()
        }
        .navigationTitle("Challenge yourself")
        .onAppear {
            loadQuizes()
        }
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
