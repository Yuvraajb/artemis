//
//  MissionDebriefView.swift
//  artemis
//
//  Mission debrief showing performance summary and insights
//

import SwiftUI

struct MissionDebriefView: View {
    @ObservedObject var viewModel: GameViewModel
    @ObservedObject var missionState: MissionStateManager
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                        
                        Text("Mission Complete")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    // Performance summary
                    VStack(spacing: 20) {
                        Text("Performance Summary")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        // Score card
                        PerformanceCard(
                            title: "Mission Score",
                            value: "\(viewModel.gameState.score)",
                            color: .cyan
                        )
                        
                        // Efficiency
                        PerformanceCard(
                            title: "Efficiency",
                            value: String(format: "%.1f%%", viewModel.gameState.efficiency),
                            color: viewModel.gameState.efficiency > 80 ? .green : (viewModel.gameState.efficiency > 60 ? .orange : .red)
                        )
                        
                        // Fuel usage
                        PerformanceCard(
                            title: "Fuel Used",
                            value: String(format: "%.1f%%", viewModel.gameState.fuelUsed),
                            color: viewModel.gameState.fuelUsed < 30 ? .green : (viewModel.gameState.fuelUsed < 50 ? .orange : .red)
                        )
                        
                        // Trajectory accuracy
                        PerformanceCard(
                            title: "Trajectory Accuracy",
                            value: String(format: "%.1f%%", viewModel.gameState.trajectoryAccuracy),
                            color: viewModel.gameState.trajectoryAccuracy > 90 ? .green : (viewModel.gameState.trajectoryAccuracy > 70 ? .orange : .red)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Decisions review
                    if !viewModel.gameState.decisions.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Decision Review")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ForEach(viewModel.gameState.decisions) { decision in
                                DecisionReviewCard(decision: decision)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Educational insights
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Key Learnings")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        InsightCard(
                            icon: "fuelpump.fill",
                            title: "Fuel Management",
                            text: "Efficient fuel allocation is critical for mission success. Conservative approaches preserve resources for later phases."
                        )
                        .padding(.horizontal, 20)
                        
                        InsightCard(
                            icon: "waveform.path",
                            title: "Orbital Mechanics",
                            text: "Trajectory burns must be timed precisely. The optimal window ensures efficient use of fuel and accurate course."
                        )
                        .padding(.horizontal, 20)
                        
                        InsightCard(
                            icon: "angle",
                            title: "Re-entry Safety",
                            text: "Re-entry angles between 5.5° and 7.5° are safe. Too shallow causes skip-out, too steep causes excessive heating."
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Continue button
                    Button(action: onComplete) {
                        HStack {
                            Text("Continue")
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
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct PerformanceCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.gray)
            
            Spacer()
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct DecisionReviewCard: View {
    let decision: GameDecision
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: decision.wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(decision.wasCorrect ? .green : .red)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(decision.question)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Choice: \(decision.choice)")
                    .font(.body)
                    .foregroundColor(.gray)
                
                Text(decision.wasCorrect ? "Correct decision" : "Could be improved")
                    .font(.caption)
                    .foregroundColor(decision.wasCorrect ? .green : .orange)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.cyan)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(text)
                    .font(.body)
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    MissionDebriefView(
        viewModel: GameViewModel(),
        missionState: MissionStateManager(),
        onComplete: {}
    )
}
