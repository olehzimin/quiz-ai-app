//
//  NavigationService.swift
//  QuizAI
//
//  Created by Oleh Zimin on 18.08.2025.
//

import SwiftUI

@Observable
final class NavigationService {
    static let shared = NavigationService()
    private init() {
        self.path = NavigationPath()
    }
    
    var path: NavigationPath
}

enum Route: Hashable {
    case add
    case edit(quiz: QuizModel)
    case game(quiz: QuizModel)
}
