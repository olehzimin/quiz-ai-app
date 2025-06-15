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
    
    @Binding var path: NavigationPath
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
                path.append("add")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
        .navigationDestination(for: Quiz.self) { quiz in
            QuizView(quiz: quiz, path: $path)
        }
        .navigationDestination(for: String.self) { value in
            if value == "add" {
                AddEditView(editMode: false)
            }
        }
        .navigationTitle("Challenge yourself")
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
