//
//  LaunchPhaseView.swift
//  artemis
//
//  Launch phase of mission simulation game
//

import SwiftUI

struct LaunchPhaseView: View {
    @ObservedObject var viewModel: GameViewModel
    let onComplete: () -> Void
    
    @State private var showDecision = false
    @State private var launchAnimationProgress: Double = 0
    @State private var rocketOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Space background with Earth
            VStack {
                Spacer()
                
                // Earth visualization
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .green, .brown],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                    )
                    .offset(y: 300 - rocketOffset)
                
                Spacer()
            }
            
            // Rocket visualization with flame effect
            VStack {
                Spacer()
                
                ZStack {
                    // Flame trail
                    if launchAnimationProgress > 0.1 {
                        VStack(spacing: 0) {
                            ForEach(0..<5, id: \.self) { index in
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [.orange, .red, .yellow],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: CGFloat(20 - index * 3), height: CGFloat(20 - index * 3))
                                    .opacity(launchAnimationProgress * (1.0 - Double(index) * 0.15))
                            }
                        }
                        .offset(y: -rocketOffset + 60)
                        .blur(radius: 2)
                    }
                    
                    // Rocket
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                        .rotationEffect(.degrees(-90))
                        .offset(y: -rocketOffset)
                        .opacity(launchAnimationProgress)
                        .shadow(color: .orange, radius: 10)
                }
                
                Spacer()
            }
            
            // Decision overlay
            if showDecision {
                DecisionOverlay(
                    title: "Fuel Allocation",
                    question: "How should we allocate fuel for launch?",
                    options: [
                        ("Conservative (95% fuel)", "Efficient but slower ascent"),
                        ("Standard (90% fuel)", "Balanced approach"),
                        ("Aggressive (85% fuel)", "Faster but riskier")
                    ],
                    correctIndex: 1, // Standard is optimal
                    onSelect: { index in
                        let isCorrect = index == 1
                        viewModel.makeDecision(
                            phase: .launch,
                            question: "Fuel Allocation",
                            choice: index == 0 ? "Conservative" : (index == 1 ? "Standard" : "Aggressive"),
                            isCorrect: isCorrect
                        )
                        
                        if isCorrect {
                            viewModel.gameState.fuel += 5
                        } else {
                            viewModel.gameState.fuel -= (index == 0 ? 2 : 5)
                        }
                        
                        withAnimation(.spring(response: 0.4)) {
                            showDecision = false
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // Instructions
            if !showDecision && launchAnimationProgress < 0.3 {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Launch Sequence")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text("Watch the launch, then make critical decisions")
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
            startLaunchSequence()
        }
    }
    
    private func startLaunchSequence() {
        // Animate rocket launch
        withAnimation(.linear(duration: 3.0)) {
            launchAnimationProgress = 1.0
            rocketOffset = 400
        }
        
        // Show decision after launch animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            withAnimation {
                showDecision = true
            }
        }
        
        // Auto-complete after decision
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            onComplete()
        }
    }
}

struct DecisionOverlay: View {
    let title: String
    let question: String
    let options: [(String, String)]
    let correctIndex: Int
    let onSelect: (Int) -> Void
    
    @State private var selectedIndex: Int?
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(question)
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        Button(action: {
                            selectedIndex = index
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSelect(index)
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.0)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text(option.1)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedIndex == index ? Color.blue.opacity(0.3) : Color.gray.opacity(0.2))
                            )
                        }
                    }
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
    LaunchPhaseView(
        viewModel: GameViewModel(),
        onComplete: {}
    )
}
