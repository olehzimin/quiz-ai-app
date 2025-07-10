//
//  QuizStartView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 13.06.2025.
//

import SwiftUI

struct QuizStartView: View {
    var quiz: Quiz
    @Binding var path: NavigationPath
    @State private var multichoiceOption: Bool = true
    @State private var flashcardOption: Bool = true
    @State private var trueFalseOption: Bool = true
    
    @State private var timerOption: Bool = false
    @State private var timerMinutes: Int = 0
    @State private var timerSeconds: Int = 20
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var chosenTasks: Int {
        var total: Int = 0
        
        if multichoiceOption { total += quiz.questionsTypeCounts[.multichoice] ?? 0 }
        if flashcardOption { total += quiz.questionsTypeCounts[.flashcard] ?? 0 }
        if trueFalseOption { total += quiz.questionsTypeCounts[.trueFalse] ?? 0 }
        
        return total
    }
    
    var body: some View {
            VStack(spacing: 0) {
                headerView
                
                Form {
                    Section {
                        if quiz.questionsTypeCounts[.multichoice] != 0 {
                            Toggle("Multichoice", isOn: $multichoiceOption).disabled(!flashcardOption && !trueFalseOption)
                        }
                        
                        if quiz.questionsTypeCounts[.flashcard] != 0 {
                            Toggle("Flashcard", isOn: $flashcardOption).disabled(!multichoiceOption && !trueFalseOption)
                        }
                        
                        if quiz.questionsTypeCounts[.trueFalse] != 0 {
                            Toggle("True / False", isOn: $trueFalseOption).disabled(!flashcardOption && !multichoiceOption)
                        }
                        
                        Text("Chosen tasks: \(chosenTasks)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .tint(Color(quiz.color))
                    .onAppear {
                        for questionTypeCount in quiz.questionsTypeCounts {
                            switch questionTypeCount {
                            case (.flashcard, 0):
                                flashcardOption = false
                            case (.multichoice, 0):
                                multichoiceOption = false
                            case (.trueFalse, 0):
                                trueFalseOption = false
                            default:
                                continue
                            }
                        }
                    }
                    
                    Section {
                        Toggle("Timer", isOn: $timerOption)
                            .tint(Color(quiz.color))
                            
                        
                        if timerOption {
                            HStack {
                                Picker("Set minutes", selection: $timerMinutes) {
                                    ForEach(0..<11) { interval in
                                        Text("\(interval) min").tag(interval)
                                    }
                                }
                                
                                Picker("Set seconds", selection: $timerSeconds) {
                                    ForEach(0..<60) { interval in
                                        if interval % 10 == 0 {
                                            Text("\(interval) s").tag(interval)
                                        }
                                    }
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                        }
                        
                    }
                    
                    Button {
                        dismiss()
                        path.append(quiz)
                        quiz.completedQuestionsCount = 0
                    } label: {
                        Text("Start Quiz")
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                Capsule()
                                    .fill(Color(quiz.color))
                            )
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .animation(.default, value: timerOption)
            .safeAreaInset(edge: .top) {
                navigationBarView
            }
    }
}

#Preview {
    if let quiz = Quiz.mock {
        QuizStartView(quiz: quiz, path: .constant(NavigationPath()))
    }
}

extension QuizStartView {
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top) {
                Text(quiz.name)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title).bold()
                
                Text("\(quiz.completedPercent)%")
                    .font(.title).bold()
                    .foregroundStyle(Color(quiz.color))
            }
            .frame(height: 70, alignment: .top)
            
            HStack(spacing: 16) {
                if let set = quiz.set {
                    Text(set)
                        .bold()
                }
                
                Text(quiz.difficulty.rawValue)
                    .foregroundStyle(.red)
                
                Text("\(quiz.questionsCount) tasks")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                ForEach(quiz.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            Color(quiz.color)
                .brightness(0.6)
                .ignoresSafeArea()
        )
        
    }
    
    private var navigationBarView: some View {
        HStack(spacing: 32) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
            
            Spacer()
            
            Button {
                dismiss()
                modelContext.delete(quiz)
            } label: {
                Image(systemName: "trash")
            }
            .foregroundStyle(.red)
            
            Button {
                
            } label: {
                Image(systemName: "pencil")
            }
        }
        .font(.title2)
        .padding(.horizontal)
        .padding(.top, 32)
        .foregroundStyle(.black)
        
    }
}
