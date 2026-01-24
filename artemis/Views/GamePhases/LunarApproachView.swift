//
//  LunarApproachView.swift
//  artemis
//
//  Lunar approach phase with course correction mechanics
//

import SwiftUI

struct LunarApproachView: View {
    @ObservedObject var viewModel: GameViewModel
    let onComplete: () -> Void
    
    @State private var showCourseCorrection = false
    @State private var moonPosition: CGPoint = CGPoint(x: 200, y: 200)
    @State private var spacecraftPosition: CGPoint = CGPoint(x: 100, y: 100)
    @State private var approachAngle: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Space visualization
            VStack {
                Spacer()
                
                ZStack {
                    // Moon
                    Circle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 120, height: 120)
                        .position(moonPosition)
                        .overlay(
                            Text("Moon")
                                .font(.caption)
                                .foregroundColor(.white)
                                .offset(y: 70)
                        )
                    
                    // Trajectory path
                    Path { path in
                        path.move(to: spacecraftPosition)
                        let endPoint = CGPoint(
                            x: moonPosition.x + cos(approachAngle) * 50,
                            y: moonPosition.y + sin(approachAngle) * 50
                        )
                        path.addLine(to: endPoint)
                    }
                    .stroke(Color.cyan.opacity(0.5), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    
                    // Spacecraft with motion trail
                    ZStack {
                        // Motion trail
                        if showCourseCorrection {
                            Path { path in
                                path.move(to: spacecraftPosition)
                                let endPoint = CGPoint(
                                    x: moonPosition.x + cos(approachAngle) * 50,
                                    y: moonPosition.y + sin(approachAngle) * 50
                                )
                                path.addLine(to: endPoint)
                            }
                            .stroke(
                                LinearGradient(
                                    colors: [.cyan.opacity(0.8), .cyan.opacity(0.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                        }
                        
                        // Spacecraft
                        Image(systemName: "capsule.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .position(spacecraftPosition)
                            .rotationEffect(.radians(approachAngle))
                            .shadow(color: .cyan, radius: 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Spacer()
            }
            
            // Course correction overlay
            if showCourseCorrection {
                CourseCorrectionView(
                    currentAngle: $approachAngle,
                    onAngleChange: { newAngle in
                        approachAngle = newAngle
                    },
                    onConfirm: {
                        // Evaluate course correction
                        let optimalAngle = atan2(
                            moonPosition.y - spacecraftPosition.y,
                            moonPosition.x - spacecraftPosition.x
                        )
                        let angleDifference = abs(approachAngle - optimalAngle)
                        let isOptimal = angleDifference < 0.3
                        
                        viewModel.makeDecision(
                            phase: .lunarApproach,
                            question: "Course Correction",
                            choice: isOptimal ? "Optimal" : "Suboptimal",
                            isCorrect: isOptimal
                        )
                        
                        if isOptimal {
                            viewModel.gameState.trajectoryAccuracy += 5
                        } else {
                            viewModel.gameState.trajectoryAccuracy -= 5
                        }
                        
                        withAnimation(.spring(response: 0.4)) {
                            showCourseCorrection = false
                        }
                        
                        // Animate approach with smooth motion
                        withAnimation(.easeInOut(duration: 2.0)) {
                            spacecraftPosition = moonPosition
                        }
                        
                        // Add visual feedback
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            onComplete()
                        }
                    }
                )
                .transition(.opacity)
            }
            
            // Instructions
            if !showCourseCorrection {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Lunar Approach")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text("Correct your course to approach the Moon")
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
            // Initialize positions
            moonPosition = CGPoint(x: UIScreen.main.bounds.width * 0.7, y: UIScreen.main.bounds.height * 0.3)
            spacecraftPosition = CGPoint(x: UIScreen.main.bounds.width * 0.3, y: UIScreen.main.bounds.height * 0.7)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation {
                    showCourseCorrection = true
                }
            }
        }
    }
}

struct CourseCorrectionView: View {
    @Binding var currentAngle: Double
    let onAngleChange: (Double) -> Void
    let onConfirm: () -> Void
    
    @State private var sliderValue: Double = 0.5
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Course Correction")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Adjust your approach angle for optimal flyby")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                // Angle slider
                VStack(spacing: 12) {
                    Text("Approach Angle: \(Int(currentAngle * 180 / .pi))°")
                        .font(.headline)
                        .foregroundColor(.cyan)
                    
                    Slider(value: $sliderValue, in: 0...1)
                        .tint(.cyan)
                        .onChange(of: sliderValue) { _, newValue in
                            // Convert slider to angle (-π to π)
                            currentAngle = (newValue - 0.5) * 2 * .pi
                            onAngleChange(currentAngle)
                        }
                    
                    HStack {
                        Text("-180°")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("0°")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        Text("180°")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                Button(action: onConfirm) {
                    Text("Confirm Course")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.cyan)
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
    LunarApproachView(
        viewModel: GameViewModel(),
        onComplete: {}
    )
}
