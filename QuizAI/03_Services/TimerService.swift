//
//  TimerUtility.swift
//  QuizAI
//
//  Created by Oleh Zimin on 12.08.2025.
//

import SwiftUI

@Observable
class TimerService {
    private(set) var remainingTime: Int = 0
    private var initialTime: Int? = nil
    private var timer: Timer? = nil
    
    func setTimer(time: Int) {
        initialTime = time
        remainingTime = time
    }
    
    func startTimer() throws {
        stopTimer()
        
        guard let initialTime else { throw TimerServiceError.missingConfig }
        remainingTime = initialTime
        
        timer = .scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

// MARK: Errors
enum TimerServiceError: Error, LocalizedError {
    case missingConfig
    
    var errorDescription: String? {
        switch self {
        case .missingConfig:
            "The timer was not set"
        }
    }
}
