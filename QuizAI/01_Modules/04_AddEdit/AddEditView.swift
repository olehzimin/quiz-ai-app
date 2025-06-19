//
//  AddEditView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 15.06.2025.
//

import SwiftUI

struct AddEditView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let editMode: Bool
    @State private var name: String = ""
    @State private var userInput: String = ""
    @State private var icon: String = ""
    @State private var difficulty: String = "Medium"
    
    private let difficultyOptions = [
        "Easy",
        "Medium",
        "Hard"
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Icon", text: $icon)
                    Text("SET - future implementation")
                    Text("TAGS - future implementation")
                }
                
                Section {
                    TextField("Topic to generate your quiz", text: $userInput, axis: .vertical)
                        .lineLimit(3)
                }
                
                Section {
                    Picker("Difficulty", selection: $difficulty) {
                        ForEach(difficultyOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                
            }
            .scrollBounceBehavior(.basedOnSize)
            
            Button {
                
            } label: {
                ZStack {
                    Capsule()
                    
                    Text("Generate")
                        .foregroundStyle(.white)
                }
                .frame(height: 60)
            }
            .padding()
            .buttonStyle(PressableButtonStyle())
        }
        .toolbar {
            Button("Save") {
                guard let questions = Quiz.mockQuestions else { return }
                
                let newQuiz = Quiz(
                    name: name,
                    set: nil,
                    tags: ["General", "Quiz", "Sample"],
                    icon: icon,
                    color: "green",
                    difficulty: .medium,
                    questions: questions
                )
                
                modelContext.insert(newQuiz)
                
                dismiss()
            }
        }
        .navigationTitle(editMode ? "Edit Quiz" : "Add Quiz")
    }
}

#Preview {
    NavigationStack {
        AddEditView(editMode: false)
    }
}
