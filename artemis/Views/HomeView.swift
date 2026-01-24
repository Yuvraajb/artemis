//
//  HomeView.swift
//  artemis
//
//  Home view showing all features in a grid
//

import SwiftUI

struct HomeView: View {
    @Binding var showMissionFlow: Bool
    @StateObject private var missionState = MissionStateManager()
    @State private var show3DModels = false
    @State private var showCrewChat = false
    @State private var showLearn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Artemis Mission")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Explore the Artemis mission through interactive experiences")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Features Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            // Mission Flow - Always unlocked
                            FeatureCard(
                                icon: "sparkles",
                                title: "Mission Flow",
                                description: "Guided mission experience",
                                gradient: [.cyan, .blue],
                                isLocked: false,
                                action: {
                                    showMissionFlow = true
                                }
                            )
                            
                            // AR Models - Locked until mission complete
                            FeatureCard(
                                icon: "cube.transparent",
                                title: "3D Models",
                                description: missionState.isMissionCompleted ? "Explore SLS & Orion" : "Complete Mission Flow to unlock",
                                gradient: [.purple, .pink],
                                isLocked: !missionState.isMissionCompleted,
                                action: {
                                    if missionState.isMissionCompleted {
                                        show3DModels = true
                                    }
                                }
                            )
                            
                            // Crew Chat - Locked until mission complete
                            FeatureCard(
                                icon: "person.3.fill",
                                title: "Crew Chat",
                                description: missionState.isMissionCompleted ? "Talk with astronauts" : "Complete Mission Flow to unlock",
                                gradient: [.orange, .red],
                                isLocked: !missionState.isMissionCompleted,
                                action: {
                                    if missionState.isMissionCompleted {
                                        showCrewChat = true
                                    }
                                }
                            )
                            
                            // Learn Cards - Locked until mission complete
                            FeatureCard(
                                icon: "book.fill",
                                title: "Learn",
                                description: missionState.isMissionCompleted ? "Educational content" : "Complete Mission Flow to unlock",
                                gradient: [.green, .mint],
                                isLocked: !missionState.isMissionCompleted,
                                action: {
                                    if missionState.isMissionCompleted {
                                        showLearn = true
                                    }
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .sheet(isPresented: $show3DModels) {
                NavigationStack {
                    ModelSelectionView()
                }
            }
            .sheet(isPresented: $showCrewChat) {
                NavigationStack {
                    CrewChatHomeView()
                }
            }
            .sheet(isPresented: $showLearn) {
                NavigationStack {
                    LearnArtemisView()
                }
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let gradient: [Color]
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                VStack(spacing: 16) {
                    ZStack {
                        Image(systemName: icon)
                            .font(.system(size: 40))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: isLocked ? [.gray, .gray] : gradient,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .opacity(isLocked ? 0.5 : 1.0)
                        
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.gray)
                                .offset(x: 20, y: -20)
                        }
                    }
                    
                    VStack(spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(isLocked ? .gray : .white)
                        
                        Text(description)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray.opacity(isLocked ? 0.05 : 0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    LinearGradient(
                                        colors: isLocked ? [.gray, .gray] : gradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isLocked ? 0.5 : 1
                                )
                        )
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLocked)
    }
}

#Preview {
    HomeView(showMissionFlow: .constant(false))
}
