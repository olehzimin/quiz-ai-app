//
//  AddView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 15.06.2025.
//

import SwiftUI

struct AddView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var quizService = QuizService.shared
    
    @State private var topic: String = ""
    @State private var icon: String = ""
    
    @State private var isDetailedTopicEnabled: Bool = false
    @State private var detailedTopic: String = ""
    
    @State private var questionsCount: Int = 5
    @State private var difficulty = QuizDifficulty.medium
    
    @State private var isMultichoiceEnabled: Bool = true
    @State private var isFlashcardEnabled: Bool = true
    @State private var isTrueFalseEnabled: Bool = true
    
    private let symbolsLimit: Int = 100
    private let counts: [Int] = Array(stride(from: 5, through: 50, by: 5))
    
    // MARK: Body
    var body: some View {
        ZStack(alignment: .bottom) {
            Form {
                Section("General") {
                    TextField("Topic", text: $topic)
                    TextField("Icon", text: $icon)
                    Text("SET - future implementation")
                    Text("TAGS - future implementation")
                }
                
                Section {
                    Toggle("Deatiled topic preferences", isOn: $isDetailedTopicEnabled)
                    
                    if isDetailedTopicEnabled {
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
                            .opacity(isDetailedTopicEnabled ? 1 : 0)
                    }
                }
                
                Section("Questions") {
                    HStack {
                        VStack {
                            Text("Count")
                            Picker("Questions count", selection: $questionsCount) {
                                ForEach(counts, id: \.self) { count in
                                    Text("\(count)").tag(count)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        
                        VStack {
                            Text("Difficulty")
                            Picker("Difficulty", selection: $difficulty) {
                                ForEach(QuizDifficulty.allCases, id: \.self) { option in
                                    Text(option.rawValue.capitalized)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                    }
                    .frame(height: 100)
                    
                    Toggle("Multichoice", isOn: $isMultichoiceEnabled).disabled(!isFlashcardEnabled && !isTrueFalseEnabled)
                    Toggle("Flashcard", isOn: $isFlashcardEnabled).disabled(!isMultichoiceEnabled && !isTrueFalseEnabled)
                    Toggle("True / False", isOn: $isTrueFalseEnabled).disabled(!isMultichoiceEnabled && !isFlashcardEnabled)
                }
                
            }
            .scrollIndicators(.hidden)
        }
        .toolbar {
            Button("Generate") {
                quizService.createQuiz(name: topic, tags: ["General", "Quiz", "Sample"], icon: icon,
                                         color: "greenQuiz", difficulty: difficulty, detailedTopic: detailedTopic,
                                       questionsCount: questionsCount, types: types(), using: modelContext)
                dismiss()
            }
            .disabled(!isValid)
        }
        .navigationTitle("Add Quiz")
        .scrollDismissesKeyboard(.immediately)
        .submitLabel(.done)
    }
}

extension AddView {
    // MARK: Computed
    private var isValid: Bool {
        !topic.isEmpty && !icon.isEmpty
    }
    
    // MARK: Methods
    private func types() -> [QuestionType] {
        var result: [QuestionType] = []
        
        if isMultichoiceEnabled { result.append(.multichoice) }
        if isFlashcardEnabled { result.append(.flashcard) }
        if isTrueFalseEnabled { result.append(.trueFalse) }
        
        return result
    }
}

// MARK: Preview
#Preview {
    NavigationStack {
        AddView()
    }
}
