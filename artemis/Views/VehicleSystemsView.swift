//
//  VehicleSystemsView.swift
//  artemis
//
//  Vehicle Systems Phase - Interactive AR/3D exploration
//

import SwiftUI

struct VehicleSystemsView: View {
    @ObservedObject var missionState: MissionStateManager
    let onComplete: () -> Void
    @State private var selectedSystem: VehicleSystem?
    
    private let systems = [
        VehicleSystem(name: "SLS Rocket", description: "Explore the Space Launch System - the most powerful rocket ever built", icon: "airplane.departure", vehicle: .sls),
        VehicleSystem(name: "Orion Capsule", description: "Discover the next-generation spacecraft designed for deep space", icon: "capsule.fill", vehicle: .orion)
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let system = selectedSystem {
                // Show 3D viewer for selected system
                ModelViewerView(vehicle: system.vehicle)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Back") {
                                selectedSystem = nil
                            }
                        }
                    }
            } else {
                // System selection view
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "airplane.departure")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("Vehicle Systems")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                            
                            Text("Explore the spacecraft and rocket systems")
                            .font(.title3)
                            .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                        
                        // Educational intro
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Understanding the Vehicles")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Tap on a vehicle to explore it in 3D and AR. Learn about each component, from the rocket stages to the crew capsule systems.")
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
                        
                        // System cards
                        ForEach(systems, id: \.name) { system in
                            VehicleSystemCard(system: system) {
                                selectedSystem = system
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Complete button
                        Button(action: onComplete) {
                            HStack {
                                Text("Continue to Crew Interaction")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
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

struct VehicleSystem {
    let name: String
    let description: String
    let icon: String
    let vehicle: VehicleModel
}

struct VehicleSystemCard: View {
    let system: VehicleSystem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 20) {
                Image(systemName: system.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                    .frame(width: 60)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(system.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(system.description)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VehicleSystemsView(missionState: MissionStateManager(), onComplete: {})
}
