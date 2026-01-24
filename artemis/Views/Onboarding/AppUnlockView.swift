//
//  AppUnlockView.swift
//  artemis
//
//  Frame 11: App Unlock - Invitation, not instruction
//

import SwiftUI

struct AppUnlockView: View {
    let onComplete: () -> Void
    
    @State private var showText = false
    @State private var showUI = false
    
    var body: some View {
        ZStack {
            // ContentView will fade in
            ContentView()
                .opacity(showUI ? 1.0 : 0.0)
            
            // Final text overlay
            if showText && !showUI {
                VStack {
                    Spacer()
                    Text("Start anywhere. Go deep.")
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                        .accessibilityLabel("Start anywhere. Go deep.")
                    Spacer()
                }
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            // Show final text
            withAnimation(.easeIn(duration: 1.0).delay(0.5)) {
                showText = true
            }
            
            // Fade in UI tabs (no animation rush)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeIn(duration: 1.5)) {
                    showUI = true
                }
            }
            
            // Complete after UI appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                onComplete()
            }
        }
    }
}
