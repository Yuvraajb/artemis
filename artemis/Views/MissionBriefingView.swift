//
//  MissionBriefingView.swift
//  artemis
//
//  Mission Briefing Phase - Introduction to Artemis mission
//

import SwiftUI

struct MissionBriefingView: View {
    @ObservedObject var missionState: MissionStateManager
    let onComplete: () -> Void
    @State private var currentSection = 0
    
    private let sections = [
        BriefingSection(
            title: "Mission Overview",
            content: "Artemis II is humanity's return to the Moon. This mission will carry four astronauts around the Moon, testing all systems before future missions land on the lunar surface.",
            icon: "moon.stars.fill"
        ),
        BriefingSection(
            title: "Mission Objectives",
            content: "• Validate Orion's life support systems\n• Test deep space communication\n• Demonstrate crew operations in deep space\n• Prepare for future lunar landings",
            icon: "checklist"
        ),
        BriefingSection(
            title: "Mission Timeline",
            content: "The mission spans 10 days: Launch from Earth → Earth orbit → Journey to Moon → Lunar flyby → Return journey → Splashdown in Pacific Ocean",
            icon: "calendar"
        ),
        BriefingSection(
            title: "The Crew",
            content: "Commander Reid Wiseman, Pilot Victor Glover, Mission Specialist Christina Koch, and Mission Specialist Jeremy Hansen will make history as the first humans to travel to the Moon in over 50 years.",
            icon: "person.3.fill"
        )
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Mission Briefing")
                            .font(.system(size: 36, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("Understanding the Artemis Mission")
                            .font(.title3)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    // Briefing Sections
                    ForEach(Array(sections.enumerated()), id: \.offset) { index, section in
                        BriefingSectionCard(section: section)
                            .padding(.horizontal, 20)
                    }
                    
                    // Continue Button
                    Button(action: onComplete) {
                        HStack {
                            Text("Mission Briefing Complete")
                            Image(systemName: "arrow.right")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct BriefingSection {
    let title: String
    let content: String
    let icon: String
}

struct BriefingSectionCard: View {
    let section: BriefingSection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: section.icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                Text(section.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(section.content)
                .font(.body)
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

#Preview {
    MissionBriefingView(missionState: MissionStateManager(), onComplete: {})
}
