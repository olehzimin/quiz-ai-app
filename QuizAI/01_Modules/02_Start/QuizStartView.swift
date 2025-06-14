//
//  QuizStartView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 13.06.2025.
//

import SwiftUI

struct QuizStartView: View {
    var quiz: Quiz
    @State private var multichoiceOption: Bool = true
    @State private var flashcardOption: Bool = true
    @State private var trueFalseOption: Bool = true
    @State private var timerOption: Bool = false
    @State private var timerMinutes: Int = 0
    @State private var timerSeconds: Int = 20
    
    var chosenTasks: Int {
        var total: Int = 0
        
        if multichoiceOption { total += quiz.questionsTypeCount[.multiChoice] ?? 0 }
        if flashcardOption { total += quiz.questionsTypeCount[.flashcard] ?? 0 }
        if trueFalseOption { total += quiz.questionsTypeCount[.trueFalse] ?? 0 }
        
        return total
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HeaderView(quiz: quiz)
                
                Form {
                    Section {
                        if quiz.questionsTypeCount[.multiChoice] != 0 {
                            Toggle("Multichoice", isOn: $multichoiceOption)
                        }
                        
                        if quiz.questionsTypeCount[.flashcard] != 0 {
                            Toggle("Flashcard", isOn: $flashcardOption)
                        }
                        
                        if quiz.questionsTypeCount[.trueFalse] != 0 {
                            Toggle("True / False", isOn: $trueFalseOption)
                        }
                        
                        Text("Chosen tasks: \(chosenTasks)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .tint(Color(quiz.color))
                    
                    Section {
                        Toggle("Timer", isOn: $timerOption)
                            .tint(Color(quiz.color))
                            
                        
                        if timerOption {
                            HStack {
                                Picker("Set minutes", selection: $timerMinutes) {
                                    ForEach(0..<11) { interval in
                                        Text("\(interval) min")
                                    }
                                }
                                
                                Picker("Set seconds", selection: $timerSeconds) {
                                    ForEach(0..<60) { interval in
                                        if interval % 10 == 0 {
                                            Text("\(interval) s")
                                        }
                                    }
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                        }
                        
                    }
                    
                    Button {
                        print("Custom action triggered")
                    } label: {
                        Text("Start Quiz")
                            .bold()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(quiz.color))
                            .cornerRadius(12)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
            .animation(.default, value: timerOption)
            .safeAreaInset(edge: .top) {
                NavigationBarView()
            }
            
        }
    }
}

#Preview {
    if let quiz = Quiz.mock {
        QuizStartView(quiz: quiz)
    }
}

fileprivate struct HeaderView: View {
    let quiz: Quiz
    
    var body: some View {
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
                
                Text(quiz.difficulty)
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
}

fileprivate struct NavigationBarView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        HStack(spacing: 32) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
            }
            
            Spacer()
            
            Button {
                
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
