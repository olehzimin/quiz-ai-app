//
//  HomeView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Quiz.name) var quizes: [Quiz]
    
    @State private var quizManager = QuizManager.shared
    @State private var showMessage: Bool = false
    
    @Binding var path: NavigationPath
    @State private var selectedQuiz: Quiz? = nil
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack {
                    ForEach(quizes, id: \.self) { quiz in
                        QuizRowView(quiz: quiz)
                            .onTapGesture {
                                selectedQuiz = quiz
                            }
                            
                            
                    }
                }
                .padding()
            }
            .sheet(item: $selectedQuiz) { quiz in
                QuizStartView(quiz: quiz, path: $path)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            
            AddButtonView {
                path.append("addView")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
        .navigationDestination(for: Quiz.self) { quiz in
            QuizView(quiz: quiz, path: $path)
        }
        .navigationDestination(for: String.self) { value in
            if value == "addView" {
                AddEditView(editMode: false)
            }
        }
        .navigationTitle("Challenge yourself")
        .toolbar {
            if quizManager.isGenerating {
                HStack {
                    Text("Generating")
                    ProgressView()
                }
            }
        }
        .onChange(of: quizManager.isGenerating) { oldValue, newValue in
            if newValue == false {
                do {
                    let newQuiz = try quizManager.getLastGeneratedQuiz()
                    modelContext.insert(newQuiz)
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView(path: .constant(NavigationPath()))
    }
    .modelContainer(for: Quiz.self, inMemory: true)
}

extension HomeView {
    func loadQuizes() {
        if let quiz = Quiz.mock {
            print("inserted")
            modelContext.insert(quiz)
        }
    }
}
