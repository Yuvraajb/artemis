//
//  MissionFlowView.swift
//  artemis
//
//  Continuous guided mission experience - no buttons, just flow
//

import SwiftUI

struct MissionFlowView: View {
    @StateObject private var missionState = MissionStateManager()
    @State private var currentStep: MissionStep = .briefing
    @State private var briefingComplete = false
    @State private var showCompletion = false
    let onDismiss: (() -> Void)?
    
    init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }
    
    enum MissionStep: Int, CaseIterable {
        case briefing = 0
        case vehicleSystems = 1
        case crewInteraction = 2
        case missionSimulation = 3
        case knowledgeLayer = 4
        case missionGame = 5
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if showCompletion {
                MissionCompleteView(
                    missionState: missionState,
                    onReset: {
                        missionState.reset()
                        showCompletion = false
                        currentStep = .briefing
                        briefingComplete = false
                    },
                    onDismiss: {
                        showCompletion = false
                    }
                )
                .transition(.opacity)
            } else {
                Group {
                    switch currentStep {
                    case .briefing:
                        GuidedBriefingView(
                            onComplete: {
                                briefingComplete = true
                                missionState.completePhase(.briefing)
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    currentStep = .vehicleSystems
                                }
                            }
                        )
                        .transition(.opacity)
                        
                    case .vehicleSystems:
                        GuidedVehicleSystemsView(
                            missionState: missionState,
                            onComplete: {
                                missionState.completePhase(.vehicleSystems)
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    currentStep = .crewInteraction
                                }
                            }
                        )
                        .transition(.opacity)
                        
                    case .crewInteraction:
                        GuidedCrewInteractionView(
                            missionState: missionState,
                            onComplete: {
                                missionState.completePhase(.crewInteraction)
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    currentStep = .missionSimulation
                                }
                            }
                        )
                        .transition(.opacity)
                        
                    case .missionSimulation:
                        GuidedMissionSimulationView(
                            missionState: missionState,
                            onComplete: {
                                missionState.completePhase(.missionSimulation)
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    currentStep = .knowledgeLayer
                                }
                            }
                        )
                        .transition(.opacity)
                        
                    case .knowledgeLayer:
                        GuidedKnowledgeLayerView(
                            missionState: missionState,
                            onComplete: {
                                missionState.completePhase(.knowledgeLayer)
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    currentStep = .missionGame
                                }
                            }
                        )
                        .transition(.opacity)
                        
                    case .missionGame:
                        ARGameView(
                            onComplete: {
                                // User chose to go back to home
                                onDismiss?()
                            }
                        )
                        .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.8), value: currentStep)
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Guided Briefing View

struct GuidedBriefingView: View {
    let onComplete: () -> Void
    @State private var currentSection = 0
    @State private var showContinue = false
    
    private let sections = [
        ("We're going back to the Moon.", "moon.stars.fill"),
        ("Artemis II will carry four astronauts around the Moon.", "person.3.fill"),
        ("Testing all systems before future missions land.", "checkmark.circle.fill"),
        ("A 10-day journey: Launch → Orbit → Moon → Return", "calendar")
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Current section content
                VStack(spacing: 24) {
                    Image(systemName: sections[currentSection].1)
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .symbolEffect(.scale.up, isActive: currentSection < sections.count)
                    
                    Text(sections[currentSection].0)
                        .font(.system(size: 32, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                
                Spacer()
                
                // Progress dots
                HStack(spacing: 8) {
                    ForEach(0..<sections.count, id: \.self) { index in
                        Circle()
                            .fill(index <= currentSection ? Color.blue : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentSection)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if currentSection < sections.count - 1 {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentSection += 1
                }
            } else {
                onComplete()
            }
        }
        .onAppear {
            // Auto-advance after delay if user doesn't tap
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                if currentSection < sections.count - 1 {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentSection += 1
                    }
                }
            }
        }
    }
}

// MARK: - Guided Vehicle Systems View

struct GuidedVehicleSystemsView: View {
    @ObservedObject var missionState: MissionStateManager
    let onComplete: () -> Void
    @State private var selectedSystem: VehicleSystem?
    @State private var hasInteracted = false
    
    private let systems = [
        VehicleSystem(name: "SLS Rocket", description: "The most powerful rocket ever built", icon: "airplane.departure", vehicle: .sls),
        VehicleSystem(name: "Orion Capsule", description: "Next-generation spacecraft for deep space", icon: "capsule.fill", vehicle: .orion)
    ]
    
    var body: some View {
        Group {
            if let system = selectedSystem {
                ModelViewerView(vehicle: system.vehicle)
                    .overlay(
                        VStack {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        selectedSystem = nil
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .padding()
                                Spacer()
                            }
                            Spacer()
                            
                            // Continue button after interaction
                            if hasInteracted {
                                Button(action: onComplete) {
                                    HStack {
                                        Text("Continue Journey")
                                        Image(systemName: "arrow.right")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.orange)
                                    .cornerRadius(16)
                                }
                                .padding()
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    )
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 40) {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Text("Explore the Vehicles")
                                .font(.system(size: 36, weight: .light, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Tap a vehicle to explore it in 3D")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        // Vehicle cards
                        VStack(spacing: 20) {
                            ForEach(systems, id: \.name) { system in
                                Button(action: {
                                    withAnimation {
                                        selectedSystem = system
                                    }
                                }) {
                                    HStack(spacing: 20) {
                                        Image(systemName: system.icon)
                                            .font(.system(size: 40))
                                            .foregroundColor(.orange)
                                            .frame(width: 60)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(system.name)
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            
                                            Text(system.description)
                                                .font(.body)
                                                .foregroundColor(.gray)
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
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: selectedSystem != nil) { _, isSelected in
            if isSelected {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    hasInteracted = true
                }
            }
        }
    }
}

// MARK: - Guided Crew Interaction View

struct GuidedCrewInteractionView: View {
    @ObservedObject var missionState: MissionStateManager
    let onComplete: () -> Void
    @State private var selectedAstronaut: Astronaut?
    @State private var hasChatted = false
    
    private let astronauts = Astronaut.sampleAstronauts
    
    var body: some View {
        Group {
            if let astronaut = selectedAstronaut {
                ChatView(astronaut: astronaut)
                    .overlay(
                        VStack {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        selectedAstronaut = nil
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(Circle())
                                }
                                .padding()
                                Spacer()
                            }
                            Spacer()
                            
                            if hasChatted {
                                Button(action: onComplete) {
                                    HStack {
                                        Text("Continue Journey")
                                        Image(systemName: "arrow.right")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.purple)
                                    .cornerRadius(16)
                                }
                                .padding()
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                    )
            } else {
                ZStack {
                    Color.black.ignoresSafeArea()
                    
                    VStack(spacing: 40) {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            Text("Meet the Crew")
                                .font(.system(size: 36, weight: .light, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Chat with the Artemis II astronauts")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        
                        // Astronaut grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(astronauts) { astronaut in
                                AstronautCard(astronaut: astronaut) {
                                    withAnimation {
                                        selectedAstronaut = astronaut
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        Spacer()
                    }
                }
            }
        }
        .onChange(of: selectedAstronaut != nil) { _, isSelected in
            if isSelected {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                    hasChatted = true
                }
            }
        }
    }
}

// MARK: - Guided Mission Simulation View

struct GuidedMissionSimulationView: View {
    @ObservedObject var missionState: MissionStateManager
    let onComplete: () -> Void
    @State private var currentTimelineIndex = 0
    @State private var showContinue = false
    
    private let timelines = [
        ("Launch", "T+0:00", "SLS launches with 8.8 million pounds of thrust", "rocket.fill", Color.orange),
        ("Earth Orbit", "T+0:08", "Orion reaches orbit, systems checks begin", "globe.americas.fill", Color.blue),
        ("Journey to Moon", "T+2:00 days", "Traveling through deep space", "moon.stars.fill", Color.purple),
        ("Lunar Flyby", "T+4:00 days", "Close approach to the Moon", "moon.fill", Color.indigo),
        ("Return Journey", "T+6:00 days", "Following free-return trajectory home", "arrow.uturn.backward", Color.cyan),
        ("Splashdown", "T+10:00 days", "Orion splashes down in the Pacific", "water.waves", Color.teal)
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Timeline visualization
                VStack(spacing: 30) {
                    Image(systemName: timelines[currentTimelineIndex].3)
                        .font(.system(size: 60))
                        .foregroundColor(timelines[currentTimelineIndex].4)
                        .symbolEffect(.scale.up, isActive: currentTimelineIndex < timelines.count)
                    
                    VStack(spacing: 12) {
                        Text(timelines[currentTimelineIndex].0)
                            .font(.system(size: 32, weight: .light, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(timelines[currentTimelineIndex].1)
                            .font(.title3)
                            .foregroundColor(.gray)
                        
                        Text(timelines[currentTimelineIndex].2)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
                
                Spacer()
                
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<timelines.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index <= currentTimelineIndex ? timelines[index].4 : Color.gray.opacity(0.3))
                            .frame(width: 30, height: 4)
                            .animation(.spring(response: 0.3), value: currentTimelineIndex)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if currentTimelineIndex < timelines.count - 1 {
                withAnimation(.easeInOut(duration: 0.5)) {
                    currentTimelineIndex += 1
                }
            } else {
                onComplete()
            }
        }
        .onAppear {
            // Auto-advance timeline
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if currentTimelineIndex < timelines.count - 1 {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        currentTimelineIndex += 1
                    }
                }
            }
        }
    }
}

// MARK: - Guided Knowledge Layer View

struct GuidedKnowledgeLayerView: View {
    @ObservedObject var missionState: MissionStateManager
    let onComplete: () -> Void
    @State private var viewedCards: Set<UUID> = []
    
    private let cards = LearnCard.sampleCards
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 12) {
                    Text("Deep Dive")
                        .font(.system(size: 36, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    Text("Swipe through to learn more")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                
                // Card stack
                LearnCardSwipeableStack(
                    cards: cards,
                    onCardTapped: { card in
                        viewedCards.insert(card.id)
                        checkCompletion()
                    },
                    onCardSwiped: { card in
                        viewedCards.insert(card.id)
                        checkCompletion()
                    }
                )
                .frame(maxHeight: .infinity)
                .padding(.horizontal, 20)
            }
        }
    }
    
    private func checkCompletion() {
        // Auto-complete after viewing all cards
        if viewedCards.count >= cards.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onComplete()
            }
        }
    }
}

struct MissionFlowView_Previews: PreviewProvider {
    static var previews: some View {
        MissionFlowView()
    }
}
