//
//  ReturnPhaseView.swift
//  artemis
//
//  Return journey and re-entry phase
//

import SwiftUI

struct ReturnPhaseView: View {
    @ObservedObject var viewModel: GameViewModel
    let onComplete: () -> Void
    
    @State private var showReentryDecision = false
    @State private var reentryAngle: Double = 6.0
    @State private var altitude: Double = 120.0
    @State private var heatShieldStatus: Double = 100.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Earth visualization
            VStack {
                Spacer()
                
                // Earth
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .green, .brown],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .overlay(
                        Circle()
                            .stroke(Color.orange.opacity(0.5), lineWidth: 3)
                            .scaleEffect(1.0 + (120 - altitude) / 120)
                    )
                
                // Spacecraft approaching with re-entry effects
                ZStack {
                    // Re-entry plasma effect
                    if altitude < 80 && altitude > 0 {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [.orange.opacity(0.6), .red.opacity(0.3), .clear],
                                    center: .center,
                                    startRadius: 10,
                                    endRadius: 40
                                )
                            )
                            .frame(width: 80, height: 80)
                            .offset(y: -altitude * 2)
                            .blur(radius: 5)
                    }
                    
                    // Spacecraft
                    Image(systemName: "capsule.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                        .offset(y: -altitude * 2)
                        .rotationEffect(.degrees(reentryAngle * 10))
                        .shadow(color: altitude < 80 ? .orange : .white, radius: altitude < 80 ? 15 : 5)
                }
                
                Spacer()
            }
            
            // Re-entry decision overlay
            if showReentryDecision {
                ReentryDecisionView(
                    currentAngle: $reentryAngle,
                    onAngleChange: { newAngle in
                        reentryAngle = newAngle
                    },
                    onConfirm: {
                        let isSafe = OrbitalPhysics.isReentryAngleSafe(angle: reentryAngle)
                        
                        viewModel.makeDecision(
                            phase: .reentry,
                            question: "Re-entry Angle",
                            choice: String(format: "%.1f°", reentryAngle),
                            isCorrect: isSafe
                        )
                        
                        if isSafe {
                            viewModel.gameState.trajectoryAccuracy += 10
                        } else {
                            viewModel.gameState.trajectoryAccuracy -= 15
                            heatShieldStatus -= 20
                        }
                        
                        withAnimation(.spring(response: 0.4)) {
                            showReentryDecision = false
                        }
                        
                        // Animate re-entry with haptic feedback simulation
                        withAnimation(.easeIn(duration: 3.0)) {
                            altitude = 0
                        }
                        
                        // Visual feedback for re-entry
                        if isSafe {
                            // Success indicator
                        } else {
                            // Warning indicator
                        }
                        
                        // Update heat shield during re-entry
                        let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                            if altitude > 0 {
                                heatShieldStatus = max(0, heatShieldStatus - 0.5)
                            } else {
                                timer.invalidate()
                                
                                // Splashdown
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    onComplete()
                                }
                            }
                        }
                        
                        RunLoop.main.add(timer, forMode: .common)
                    }
                )
                .transition(.opacity)
            }
            
            // Heat shield indicator
            if !showReentryDecision && altitude < 120 {
                VStack {
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Heat Shield")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            HStack(spacing: 4) {
                                ForEach(0..<10, id: \.self) { index in
                                    Rectangle()
                                        .fill(index < Int(heatShieldStatus / 10) ? Color.green : Color.red.opacity(0.3))
                                        .frame(width: 8, height: 20)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.black.opacity(0.7))
                        )
                        .padding()
                    }
                    
                    Spacer()
                }
            }
            
            // Instructions
            if !showReentryDecision && altitude >= 120 {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Return Journey")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text("Prepare for re-entry. Choose the optimal angle.")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.7))
                    )
                    .padding()
                    
                    Spacer().frame(height: 200)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showReentryDecision = true
                }
            }
        }
    }
}

struct ReentryDecisionView: View {
    @Binding var currentAngle: Double
    let onAngleChange: (Double) -> Void
    let onConfirm: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Re-entry Angle")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Choose the optimal re-entry angle (5.5° - 7.5° is safe)")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                // Angle display
                VStack(spacing: 12) {
                    Text(String(format: "%.1f°", currentAngle))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(
                            OrbitalPhysics.isReentryAngleSafe(angle: currentAngle) ? .green : .orange
                        )
                    
                    // Angle slider
                    Slider(value: $currentAngle, in: 4.0...9.0, step: 0.1)
                        .tint(
                            OrbitalPhysics.isReentryAngleSafe(angle: currentAngle) ? .green : .orange
                        )
                        .onChange(of: currentAngle) { _, newValue in
                            onAngleChange(newValue)
                        }
                    
                    HStack {
                        Text("4°")
                            .font(.caption)
                            .foregroundColor(.red)
                        Spacer()
                        
                        // Safe zone indicator
                        HStack(spacing: 4) {
                            Text("Safe: 5.5° - 7.5°")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        Spacer()
                        Text("9°")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding()
                
                // Warning if unsafe
                if !OrbitalPhysics.isReentryAngleSafe(angle: currentAngle) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text("Angle outside safe range - risk of mission failure")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orange.opacity(0.2))
                    )
                }
                
                Button(action: onConfirm) {
                    Text("Confirm Re-entry")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            OrbitalPhysics.isReentryAngleSafe(angle: currentAngle) ? Color.green : Color.orange
                        )
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.9))
            )
            .padding()
        }
    }
}

#Preview {
    ReturnPhaseView(
        viewModel: GameViewModel(),
        onComplete: {}
    )
}
