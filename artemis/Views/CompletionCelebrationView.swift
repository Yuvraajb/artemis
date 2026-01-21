//
//  CompletionCelebrationView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

/// Celebratory completion view using native SwiftUI components
struct CompletionCelebrationView: View {
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Main icon with native symbol effects
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.yellow, .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.scale.up, options: .repeating)
            
            // Text content
            VStack(spacing: 16) {
                Text("You're all caught up,")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("genius!")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("You've explored all the cards")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Start Over button using native button style
            Button(action: onReset) {
                Label("Start Over", systemImage: "arrow.clockwise")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 50)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.ignoresSafeArea())
    }
}

#Preview {
    CompletionCelebrationView(onReset: {})
        .preferredColorScheme(.dark)
}
