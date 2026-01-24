//
//  CrewInteractionView.swift
//  artemis
//
//  Crew Interaction Phase - Chat with astronauts with role-based scenarios
//

import SwiftUI

struct CrewInteractionView: View {
    @ObservedObject var missionState: MissionStateManager
    let onComplete: () -> Void
    @State private var selectedAstronaut: Astronaut?
    
    private let astronauts = Astronaut.sampleAstronauts
    
    private let scenarios = [
        Scenario(title: "Launch Preparation", description: "Discuss pre-launch procedures and crew roles", icon: "rocket.fill"),
        Scenario(title: "System Malfunction", description: "How would you handle an emergency in space?", icon: "exclamationmark.triangle.fill"),
        Scenario(title: "Mission Objectives", description: "Learn about the goals of Artemis II", icon: "target"),
        Scenario(title: "Deep Space Experience", description: "What's it like traveling to the Moon?", icon: "moon.stars.fill")
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let astronaut = selectedAstronaut {
                // Show chat view
                ChatView(astronaut: astronaut)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back") {
                                selectedAstronaut = nil
                            }
                        }
                    }
            } else {
                // Crew selection view
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "person.3.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.purple)
                            
                            Text("Crew Interaction")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Chat with the Artemis II crew members")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                        
                        // Educational intro
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Meet the Crew")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Each crew member has unique expertise and responsibilities. Tap on an astronaut to start a conversation and learn about their role in the mission.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .padding(.horizontal, 20)
                        
                        // Scenario suggestions
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Conversation Topics")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(scenarios, id: \.title) { scenario in
                                        ScenarioChip(scenario: scenario)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Astronaut grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(astronauts) { astronaut in
                                AstronautCard(astronaut: astronaut) {
                                    selectedAstronaut = astronaut
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Complete button
                        Button(action: onComplete) {
                            HStack {
                                Text("Continue to Mission Simulation")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct Scenario {
    let title: String
    let description: String
    let icon: String
}

struct ScenarioChip: View {
    let scenario: Scenario
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: scenario.icon)
                .font(.title3)
                .foregroundColor(.purple)
            
            Text(scenario.title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text(scenario.description)
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(2)
        }
        .padding(12)
        .frame(width: 140)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    CrewInteractionView(missionState: MissionStateManager(), onComplete: {})
}
