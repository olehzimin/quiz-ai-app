//
//  AddButtonView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 13.06.2025.
//

import SwiftUI

struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1.0)
            .brightness(configuration.isPressed ? 0.2 : 0.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct AddButtonView: View {
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                
                Image(systemName: "plus")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .padding(16)
            }
            .frame(width: 60, height: 60)
        }
        .buttonStyle(PressableButtonStyle())
    }
}

#Preview {
    AddButtonView {
        
    }
}
