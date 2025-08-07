//
//  AddForm.swift
//  QuizAI
//
//  Created by Oleh Zimin on 15.06.2025.
//

import SwiftUI

struct AddForm: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let editMode: Bool
    
    @State private var name: String = ""
    @State private var icon: String = ""
    
    @State private var optionalTopicPreferences: Bool = false
    @State private var detailedTopic: String = ""
    private let symbolsLimit = 100
    
    @State private var questionsCount: Int = 5
    @State private var difficulty = QuizDifficulty.medium
    
    @State private var multichoiceOption: Bool = true
    @State private var flashcardOption: Bool = true
    @State private var trueFalseOption: Bool = true
    
    @State private var quizManager = QuizService.shared
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section("General") {
                    TextField("Name", text: $name)
                    TextField("Icon", text: $icon)
                    Text("SET - future implementation")
                    Text("TAGS - future implementation")
                }
                
                Section {
                    Toggle("Optional topic preferences", isOn: $optionalTopicPreferences)
                    
                    if optionalTopicPreferences {
                        TextField("Additional info about topic", text: $detailedTopic, axis: .vertical)
                            .lineLimit(3)
                            .onChange(of: detailedTopic) { oldValue, newValue in
                                if newValue.count > symbolsLimit {
                                    detailedTopic = oldValue
                                }
                            }
                    }
                } footer: {
                    HStack {
                        Spacer()
                        Text("\(detailedTopic.count)/\(symbolsLimit)")
                            .opacity(optionalTopicPreferences ? 1 : 0)
                    }
                }
                
                Section("Questions") {
                    HStack {
                        VStack {
                            Text("Count")
                            Picker("Questions count", selection: $questionsCount) {
                                ForEach(5..<101) { number in
                                    if number % 5 == 0 {
                                        Text("\(number)").tag(number)
                                    }
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                        }
                        
                        VStack {
                            Text("Difficulty")
                            Picker("Difficulty", selection: $difficulty) {
                                ForEach(QuizDifficulty.allCases, id: \.self) { option in
                                    Text(option.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                        }
                    }
                    
                    Toggle("Multichoice", isOn: $multichoiceOption).disabled(!flashcardOption && !trueFalseOption)
                    Toggle("Flashcard", isOn: $flashcardOption).disabled(!multichoiceOption && !trueFalseOption)
                    Toggle("True / False", isOn: $trueFalseOption).disabled(!multichoiceOption && !flashcardOption)
                }
                
            }
            .scrollIndicators(.hidden)
            .submitLabel(.done)
        }
        .toolbar {
            Button(editMode ? "Save" : "Generate") {
                quizManager.generateQuiz(name: name, tags: ["General", "Quiz", "Sample"], icon: icon, color: "greenQuiz",
                                         difficulty: difficulty, detailedTopic: detailedTopic, questionsCount: questionsCount, types: types)
                dismiss()
            }
            .disabled(!isValid)
        }
        .navigationTitle(editMode ? "Edit Quiz" : "Add Quiz")
        .scrollDismissesKeyboard(.immediately)
    }
}

#Preview {
    NavigationStack {
        AddForm(editMode: false)
    }
}

extension AddForm {
    private var isValid: Bool {
        var result = false
        
        if !name.isEmpty && !icon.isEmpty {
            result = true
        }
            
        return result
    }
    
    private var types: [QuestionType] {
        var result: [QuestionType] = []
        
        if multichoiceOption { result.append(.multichoice) }
        if flashcardOption { result.append(.flashcard) }
        if trueFalseOption { result.append(.trueFalse) }
        
        return result
    }
}
