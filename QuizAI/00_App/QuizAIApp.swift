//
//  QuizAIApp.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.06.2025.
//

import SwiftUI
import SwiftData

@main
struct QuizAIApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: Quiz.self)
        }
    }
}
