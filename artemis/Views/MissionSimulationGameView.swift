//
//  MissionSimulationGameView.swift
//  artemis
//
//  Main game container for Mission Simulation Game
//

import SwiftUI

struct MissionSimulationGameView: View {
    @StateObject private var viewModel = GameViewModel()
    @ObservedObject var missionState: MissionStateManager
    let onComplete: () -> Void
    
    @State private var showIntroduction = true
    @State private var showHUD = false
    
    var body: some View {
        ZStack {
            // Game content
            Group {
                switch viewModel.gameState.currentPhase {
                case .introduction:
                    GameIntroductionView(
                        onStart: {
                            showIntroduction = false
                            showHUD = true
                            viewModel.startMission()
                        }
                    )
                    
                case .launch:
                    LaunchPhaseView(
                        viewModel: viewModel,
                        onComplete: {
                            viewModel.advanceToNextPhase()
                        }
                    )
                    
                case .orbit:
                    OrbitPhaseView(
                        viewModel: viewModel,
                        onComplete: {
                            viewModel.advanceToNextPhase()
                        }
                    )
                    
                case .lunarApproach:
                    LunarApproachView(
                        viewModel: viewModel,
                        onComplete: {
                            viewModel.advanceToNextPhase()
                        }
                    )
                    
                case .returnJourney:
                    ReturnPhaseView(
                        viewModel: viewModel,
                        onComplete: {
                            viewModel.advanceToNextPhase()
                        }
                    )
                    
                case .reentry:
                    ReturnPhaseView(
                        viewModel: viewModel,
                        onComplete: {
                            viewModel.advanceToNextPhase()
                        }
                    )
                    
                case .debrief:
                    MissionDebriefView(
                        viewModel: viewModel,
                        missionState: missionState,
                        onComplete: {
                            missionState.completePhase(.missionSimulation)
                            onComplete()
                        }
                    )
                }
            }
            .transition(.opacity)
            
            // HUD overlay (shown during active gameplay)
            if showHUD && viewModel.gameState.currentPhase != .introduction && viewModel.gameState.currentPhase != .debrief {
                GameHUD(gameState: viewModel.gameState)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showHUD)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: viewModel.gameState.currentPhase)
        .preferredColorScheme(.dark)
    }
}

struct GameIntroductionView: View {
    let onStart: () -> Void
    
    @State private var currentMessage = 0
    
    private let messages = [
        "You are Mission Commander",
        "Pilot Orion through critical mission phases",
        "Make decisions that affect mission success",
        "Learn orbital mechanics through experience"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Mission icon
                Image(systemName: "rocket.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.cyan)
                    .symbolEffect(.scale.up, isActive: currentMessage < messages.count)
                
                // Current message
                Text(messages[currentMessage])
                    .font(.system(size: 28, weight: .light, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .transition(.opacity)
                
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<messages.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentMessage ? Color.cyan : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                
                Spacer()
                
                // Start button (shown after all messages)
                if currentMessage >= messages.count - 1 {
                    Button(action: onStart) {
                        HStack {
                            Text("Begin Mission")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 60)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if currentMessage < messages.count - 1 {
                withAnimation {
                    currentMessage += 1
                }
            }
        }
        .onAppear {
            // Auto-advance messages
            for i in 1..<messages.count {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 2.0) {
                    withAnimation {
                        currentMessage = i
                    }
                }
            }
        }
    }
}

#Preview {
    MissionSimulationGameView(
        missionState: MissionStateManager(),
        onComplete: {}
    )
}
