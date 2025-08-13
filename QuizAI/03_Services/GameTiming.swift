//
//  GameTiming.swift
//  QuizAI
//
//  Created by Oleh Zimin on 13.08.2025.
//

import SwiftUI

enum GameTiming: Equatable {
    case unlimited
    case countdown(seconds: Int)
    
    var isTimed: Bool {
        if case .countdown = self { return true }
        return false
    }
}
