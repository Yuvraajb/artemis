//
//  MissionSimulationView.swift
//  artemis
//
//  Mission Simulation Phase - Launch sequence and timeline
//

import SwiftUI

struct MissionSimulationView: View {
    @ObservedObject var missionState: MissionStateManager
    let onComplete: () -> Void
    @State private var selectedTimeline: MissionTimeline?
    
    private let timelines = [
        MissionTimeline(
            phase: "Launch",
            time: "T+0:00",
            description: "SLS rocket launches from Kennedy Space Center with 8.8 million pounds of thrust",
            icon: "rocket.fill",
            color: .orange
        ),
        MissionTimeline(
            phase: "Earth Orbit",
            time: "T+0:08",
            description: "Orion reaches Earth orbit. Crew performs systems checks and prepares for translunar injection",
            icon: "globe.americas.fill",
            color: .blue
        ),
        MissionTimeline(
            phase: "Journey to Moon",
            time: "T+2:00 days",
            description: "Crew travels through deep space, testing systems and conducting experiments",
            icon: "moon.stars.fill",
            color: .purple
        ),
        MissionTimeline(
            phase: "Lunar Flyby",
            time: "T+4:00 days",
            description: "Orion performs a close flyby of the Moon, coming within thousands of miles of the surface",
            icon: "moon.fill",
            color: .indigo
        ),
        MissionTimeline(
            phase: "Return Journey",
            time: "T+6:00 days",
            description: "Following free-return trajectory, Orion begins journey back to Earth",
            icon: "arrow.uturn.backward",
            color: .cyan
        ),
        MissionTimeline(
            phase: "Splashdown",
            time: "T+10:00 days",
            description: "Orion splashes down in the Pacific Ocean. Recovery teams retrieve crew and spacecraft",
            icon: "water.waves",
            color: .teal
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "rocket.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("Mission Simulation")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Experience the 10-day journey to the Moon")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Educational intro
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Mission Timeline")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Follow the Artemis II mission from launch to splashdown. Each phase represents critical milestones in the journey to the Moon and back.")
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
                    
                    // Timeline phases
                    VStack(spacing: 16) {
                        ForEach(Array(timelines.enumerated()), id: \.offset) { index, timeline in
                            TimelinePhaseCard(timeline: timeline, index: index)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Launch sequence button
                    Button(action: {
                        // Could navigate to a detailed launch sequence view
                        onComplete()
                    }) {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Experience Launch Sequence")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.orange, .red],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    
                    // Complete button
                    Button(action: onComplete) {
                        HStack {
                            Text("Continue to Knowledge Layer")
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
                    .padding(.top, 8)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MissionTimeline {
    let phase: String
    let time: String
    let description: String
    let icon: String
    let color: Color
}

struct TimelinePhaseCard: View {
    let timeline: MissionTimeline
    let index: Int
    
    var body: some View {
        HStack(spacing: 20) {
            // Timeline indicator
            VStack {
                ZStack {
                    Circle()
                        .fill(timeline.color)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: timeline.icon)
                        .foregroundColor(.white)
                        .font(.system(size: 20))
                }
                
                if index < 5 {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 2, height: 60)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(timeline.phase)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(timeline.time)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                        )
                }
                
                Text(timeline.description)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    MissionSimulationView(missionState: MissionStateManager(), onComplete: {})
}
