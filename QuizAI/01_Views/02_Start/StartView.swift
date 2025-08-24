//
//  StartView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 13.06.2025.
//

import SwiftUI

struct StartView: View {
    let quiz: QuizModel
    
    @Environment(NavigationService.self) private var navigationService
    @Environment(GameService.self) private var gameService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var isMultichoiceEnabled: Bool = true
    @State private var isFlashcardEnabled: Bool = true
    @State private var isTrueFalseEnabled: Bool = true
    
    @State private var isTimerEnabled: Bool = false
    @State private var timerMinutes: Int = 0
    @State private var timerSeconds: Int = 20
    
    private let minutesRange: [Int] = Array(0...10)
    private let secondsRange: [Int] = Array(stride(from: 0, through: 50, by: 10))
    
    // MARK: Body
    var body: some View {
            VStack(spacing: 0) {
                headerView
                
                Form {
                    Section {
                        if quiz.questionsTypeCounts[.multichoice] != 0 {
                            Toggle("Multichoice", isOn: $isMultichoiceEnabled).disabled(!isFlashcardEnabled && !isTrueFalseEnabled)
                        }
                        
                        if quiz.questionsTypeCounts[.flashcard] != 0 {
                            Toggle("Flashcard", isOn: $isFlashcardEnabled).disabled(!isMultichoiceEnabled && !isTrueFalseEnabled)
                        }
                        
                        if quiz.questionsTypeCounts[.trueFalse] != 0 {
                            Toggle("True / False", isOn: $isTrueFalseEnabled).disabled(!isFlashcardEnabled && !isMultichoiceEnabled)
                        }
                    } footer: {
                        Text("Chosen tasks: \(chosenTasks)")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .tint(Color(quiz.color))
                    .onAppear {
                        disableEmptyTypes()
                    }
                    
                    Section {
                        Toggle("Timer", isOn: $isTimerEnabled)
                            .tint(Color(quiz.color))
                            
                        
                        if isTimerEnabled {
                            HStack {
                                Picker("Set minutes", selection: $timerMinutes) {
                                    ForEach(minutesRange, id: \.self) { interval in
                                        Text("\(interval) min").tag(interval)
                                    }
                                }
                                
                                Picker("Set seconds", selection: $timerSeconds) {
                                    ForEach(secondsRange, id: \.self) { interval in
                                        Text("\(interval) s").tag(interval)
                                    }
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 100)
                        }
                        
                    }
                    .onChange(of: timerMinutes) { _, newValue in
                        withAnimation {
                            validateMitutes(newValue)
                        }
                    }
                    .onChange(of: timerSeconds) { _, newValue in
                        withAnimation {
                            validateSeconds(newValue)
                        }
                    }
                    
                    Button {
                        dismiss()
                        gameService.setGame(with: quiz, timing: timing)
                        navigationService.path.append(Route.game(quiz: quiz))
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
            .animation(.default, value: isTimerEnabled)
            .safeAreaInset(edge: .top) {
                navigationBarView
            }
    }
}

extension StartView {
    // MARK: Computed
    var chosenTasks: Int {
        var total: Int = 0
        
        if isMultichoiceEnabled { total += quiz.questionsTypeCounts[.multichoice] ?? 0 }
        if isFlashcardEnabled { total += quiz.questionsTypeCounts[.flashcard] ?? 0 }
        if isTrueFalseEnabled { total += quiz.questionsTypeCounts[.trueFalse] ?? 0 }
        
        return total
    }
    
    var timing: GameTiming {
        guard isTimerEnabled else { return .unlimited }
        let total = timerMinutes*60 + timerSeconds
        
        return .countdown(seconds: total)
    }
    
    // MARK: Methods
    private func disableEmptyTypes() {
        for questionTypeCount in quiz.questionsTypeCounts {
            switch questionTypeCount {
            case (.flashcard, 0):
                isFlashcardEnabled = false
            case (.multichoice, 0):
                isMultichoiceEnabled = false
            case (.trueFalse, 0):
                isTrueFalseEnabled = false
            default:
                continue
            }
        }
    }
    
    private func validateMitutes(_ minutes: Int) {
        if minutes == 0 && timerSeconds == 0 {
            timerSeconds = secondsRange[1]
        }
    }
    
    private func validateSeconds(_ seconds: Int) {
        if seconds == 0 && timerMinutes == 0 {
            timerMinutes = minutesRange[1]
        }
    }
    
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
                dismiss()
                navigationService.path.append(Route.edit(quiz: quiz))
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

// MARK: Preview
#Preview {
    let quiz = QuizModel.mockQuiz()
    
    return
    StartView(quiz: quiz)
        .environment(NavigationService.shared)
        .environment(GameService.shared)
}
