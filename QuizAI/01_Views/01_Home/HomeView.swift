//
//  HomeView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Binding var path: NavigationPath
    
    @Query(sort: \QuizModel.name) var quizes: [QuizModel]
    
    @Environment(\.modelContext) var modelContext
    
    @State private var selectedQuiz: QuizModel? = nil
    @State private var quizService = QuizService.shared
    @State private var showsAlert: Bool = false
    
    // MARK: Body
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
                StartView(quiz: quiz, path: $path)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            
            AddButton {
                path.append("addView")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding()
        }
        .navigationDestination(for: QuizModel.self) { quiz in
            GameView(path: $path)
        }
        .navigationDestination(for: String.self) { value in
            if value == "addView" {
                AddView()
            }
        }
        .navigationTitle("Challenge yourself")
        .toolbar {
            if quizService.generationPhase == .generating {
                HStack {
                    Text("Generating")
                    ProgressView()
                }
            }
        }
        .alert("No quiz was created!", isPresented: $showsAlert) {
            Button("OK") { }
        } message: {
            Text(quizService.alertMessage ?? "")
        }
        .onChange(of: quizService.generationPhase) { oldValue, newValue in
            if newValue == .finished {
                if quizService.alertMessage != nil {
                    showsAlert = true
                }
                
                do {
                    let newQuiz = try quizService.getLastGeneratedQuiz()
                    modelContext.insert(newQuiz)
                } catch {
                    print(error)
                }
            }
        }
    }
}

// MARK: Preview
#Preview {
    NavigationStack {
        HomeView(path: .constant(NavigationPath()))
    }
    .modelContainer(for: QuizModel.self, inMemory: true)
}
