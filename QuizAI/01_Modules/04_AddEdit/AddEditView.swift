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
    @State private var icon: String = ""
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            Text("SET - future implementation")
            Text("TAGS - future implementation")
            TextField("Icon", text: $icon)
            Text("Difficulty")
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
                    difficulty: "Medium",
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
