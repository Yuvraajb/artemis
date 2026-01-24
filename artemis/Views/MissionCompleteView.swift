//
//  MissionCompleteView.swift
//  artemis
//
//  Celebration view when all mission phases are completed
//

import SwiftUI

struct MissionCompleteView: View {
    @ObservedObject var missionState: MissionStateManager
    let onReset: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Celebration icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 120))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.cyan, .blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.scale.up, options: .repeating)
                
                // Text content
                VStack(spacing: 16) {
                    Text("Mission Complete!")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("You've completed all phases of the Artemis mission")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // Completion stats
                    VStack(spacing: 12) {
                        HStack(spacing: 20) {
                            StatBadge(icon: "checkmark.circle.fill", count: missionState.completedPhases.count, label: "Phases")
                            StatBadge(icon: "sparkles", count: 5, label: "Systems")
                            StatBadge(icon: "person.3.fill", count: 4, label: "Crew")
                        }
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: onReset) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Start New Mission")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    
                    Button(action: onDismiss) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back to Mission")
                        }
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct StatBadge: View {
    let icon: String
    let count: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.cyan)
            
            Text("\(count)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(16)
        .frame(width: 100)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    MissionCompleteView(missionState: MissionStateManager(), onReset: {}, onDismiss: {})
}
