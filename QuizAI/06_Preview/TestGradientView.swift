//
//  TestGradientView.swift
//  QuizAI
//
//  Created by Oleh Zimin on 09.07.2025.
//

import SwiftUI

struct TestGradientView: View {
    @State private var gradientPoints: (startPoint: UnitPoint, endPoint: UnitPoint) = (.bottomLeading, .topTrailing)
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(colors: [.yellow, .purple, .green], startPoint: gradientPoints.startPoint, endPoint: gradientPoints.endPoint))
                .mask {
                    RoundedRectangle(cornerRadius: 80)
                        .stroke(lineWidth: 50)
                        .blur(radius: 30)
                }
                .onTapGesture {
                    gradientPoints = (.top, .bottom)
                }
                .animation(.bouncy(duration: 5), value: gradientPoints.startPoint)
                
        }
//        .frame(width: 300, height: 500)
        .ignoresSafeArea()
    }
}

#Preview {
    TestGradientView()
}
