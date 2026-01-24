//
//  OrbitPhaseView.swift
//  artemis
//
//  Orbit phase with trajectory burn mechanics
//

import SwiftUI

struct OrbitPhaseView: View {
    @ObservedObject var viewModel: GameViewModel
    let onComplete: () -> Void
    
    @State private var showSystemsCheck = false
    @State private var showTrajectoryBurn = false
    @State private var burnProgress: Double = 0
    @State private var trajectoryPoints: [CGPoint] = []
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            // Orbital visualization
            VStack {
                Spacer()
                
                // Earth
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue, .green],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 150, height: 150)
                
                // Orbit path
                if !trajectoryPoints.isEmpty {
                    Path { path in
                        path.move(to: CGPoint(x: 200, y: 200))
                        for point in trajectoryPoints {
                            path.addLine(to: CGPoint(x: 200 + point.x, y: 200 + point.y))
                        }
                    }
                    .stroke(Color.cyan.opacity(0.5), lineWidth: 2)
                }
                
                // Orion spacecraft with orbital motion
                Image(systemName: "capsule.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .offset(x: 200, y: 200)
                    .rotationEffect(.degrees(burnProgress * 360))
                    .shadow(color: .cyan, radius: 5)
                    .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: burnProgress)
                
                Spacer()
            }
            
            // Systems check overlay
            if showSystemsCheck {
                SystemsCheckView(
                    systems: viewModel.gameState.systemsStatus,
                    onComplete: { allOperational in
                        withAnimation(.spring(response: 0.4)) {
                            showSystemsCheck = false
                        }
                        if allOperational {
                            viewModel.performSystemCheck()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(.spring(response: 0.4)) {
                                    showTrajectoryBurn = true
                                }
                            }
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // Trajectory burn overlay
            if showTrajectoryBurn {
                TrajectoryBurnView(
                    progress: $burnProgress,
                    onComplete: {
                        withAnimation(.spring(response: 0.4)) {
                            showTrajectoryBurn = false
                        }
                        viewModel.makeDecision(
                            phase: .orbit,
                            question: "Trajectory Burn Timing",
                            choice: burnProgress > 0.8 && burnProgress < 1.0 ? "Optimal" : "Suboptimal",
                            isCorrect: burnProgress > 0.8 && burnProgress < 1.0
                        )
                        
                        // Calculate trajectory with animation
                        withAnimation(.easeInOut(duration: 1.0)) {
                            trajectoryPoints = viewModel.getTrajectoryPoints()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            onComplete()
                        }
                    }
                )
                .transition(.opacity)
            }
            
            // Instructions
            if !showSystemsCheck && !showTrajectoryBurn {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Text("Earth Orbit")
                            .font(.title)
                            .foregroundColor(.white)
                        
                        Text("Perform systems check, then execute trajectory burn")
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
                    showSystemsCheck = true
                }
            }
        }
    }
}

struct SystemsCheckView: View {
    let systems: [String: Bool]
    let onComplete: (Bool) -> Void
    
    @State private var checkedSystems: Set<String> = []
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Systems Check")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 12) {
                    ForEach(Array(systems.keys.sorted()), id: \.self) { systemName in
                        HStack {
                            Text(systemName.capitalized)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            if checkedSystems.contains(systemName) {
                                Image(systemName: systems[systemName] == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(systems[systemName] == true ? .green : .red)
                            } else {
                                Button(action: {
                                    checkedSystems.insert(systemName)
                                    
                                    if checkedSystems.count == systems.count {
                                        let allOperational = systems.values.allSatisfy { $0 }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            onComplete(allOperational)
                                        }
                                    }
                                }) {
                                    Image(systemName: "circle")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.2))
                        )
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

struct TrajectoryBurnView: View {
    @Binding var progress: Double
    let onComplete: () -> Void
    
    @State private var isBurning = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Text("Trajectory Burn")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Tap when the indicator is in the optimal zone")
                    .font(.body)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                // Progress indicator
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 40)
                        
                        // Optimal zone (80-100%)
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.3))
                            .frame(width: geometry.size.width * 0.2, height: 40)
                            .offset(x: geometry.size.width * 0.8)
                        
                        // Progress indicator
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.cyan)
                            .frame(width: geometry.size.width * progress, height: 40)
                        
                        // Current position marker
                        Circle()
                            .fill(Color.white)
                            .frame(width: 12, height: 12)
                            .offset(x: geometry.size.width * progress - 6)
                    }
                }
                .frame(height: 40)
                .padding(.horizontal)
                
                if !isBurning {
                    Button(action: {
                        isBurning = true
                        startBurn()
                    }) {
                        Text("Start Burn")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                } else {
                    Text("Burning...")
                        .font(.headline)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.9))
            )
            .padding()
        }
    }
    
    private func startBurn() {
        // Animate progress
        withAnimation(.linear(duration: 3.0)) {
            progress = 1.0
        }
        
        // Auto-complete after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            onComplete()
        }
    }
}

#Preview {
    OrbitPhaseView(
        viewModel: GameViewModel(),
        onComplete: {}
    )
}
