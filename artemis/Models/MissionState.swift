//
//  MissionState.swift
//  artemis
//
//  Mission progression state management
//

import Foundation
import SwiftUI
import Combine

/// Mission phases that unlock progressively
enum MissionPhase: String, CaseIterable, Identifiable {
    case briefing = "briefing"
    case vehicleSystems = "vehicle_systems"
    case crewInteraction = "crew_interaction"
    case missionSimulation = "mission_simulation"
    case knowledgeLayer = "knowledge_layer"
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .briefing: return "Mission Briefing"
        case .vehicleSystems: return "Vehicle Systems"
        case .crewInteraction: return "Crew Interaction"
        case .missionSimulation: return "Mission Simulation"
        case .knowledgeLayer: return "Knowledge Layer"
        }
    }
    
    var icon: String {
        switch self {
        case .briefing: return "doc.text.fill"
        case .vehicleSystems: return "airplane.departure"
        case .crewInteraction: return "person.3.fill"
        case .missionSimulation: return "rocket.fill"
        case .knowledgeLayer: return "sparkles"
        }
    }
    
    var description: String {
        switch self {
        case .briefing: return "Understand the Artemis mission goals and objectives"
        case .vehicleSystems: return "Explore the SLS rocket and Orion spacecraft systems"
        case .crewInteraction: return "Interact with the Artemis II crew members"
        case .missionSimulation: return "Experience the mission timeline and launch sequence"
        case .knowledgeLayer: return "Deep dive into mission concepts and facts"
        }
    }
}

/// Manages mission progression and unlocks
class MissionStateManager: ObservableObject {
    @Published var unlockedPhases: Set<MissionPhase> = [.briefing]
    @Published var currentPhase: MissionPhase = .briefing
    @Published var completedPhases: Set<MissionPhase> = []
    
    init() {
        // Load saved state if available
        loadState()
    }
    
    func unlockPhase(_ phase: MissionPhase) {
        unlockedPhases.insert(phase)
        saveState()
    }
    
    func completePhase(_ phase: MissionPhase) {
        completedPhases.insert(phase)
        
        // Auto-unlock next phase
        if let currentIndex = MissionPhase.allCases.firstIndex(of: phase),
           currentIndex < MissionPhase.allCases.count - 1 {
            let nextPhase = MissionPhase.allCases[currentIndex + 1]
            unlockPhase(nextPhase)
        }
        
        saveState()
    }
    
    func isUnlocked(_ phase: MissionPhase) -> Bool {
        unlockedPhases.contains(phase)
    }
    
    func isCompleted(_ phase: MissionPhase) -> Bool {
        completedPhases.contains(phase)
    }
    
    private func saveState() {
        // Save to UserDefaults
        let unlockedKeys = unlockedPhases.map { $0.rawValue }
        let completedKeys = completedPhases.map { $0.rawValue }
        UserDefaults.standard.set(unlockedKeys, forKey: "unlockedPhases")
        UserDefaults.standard.set(completedKeys, forKey: "completedPhases")
    }
    
    private func loadState() {
        if let unlockedKeys = UserDefaults.standard.array(forKey: "unlockedPhases") as? [String] {
            unlockedPhases = Set(unlockedKeys.compactMap { MissionPhase(rawValue: $0) })
        }
        if let completedKeys = UserDefaults.standard.array(forKey: "completedPhases") as? [String] {
            completedPhases = Set(completedKeys.compactMap { MissionPhase(rawValue: $0) })
        }
    }
    
    func reset() {
        unlockedPhases = [.briefing]
        completedPhases = []
        currentPhase = .briefing
        UserDefaults.standard.removeObject(forKey: "missionCompleted")
        saveState()
    }
    
    var isMissionCompleted: Bool {
        // Check if all phases are completed
        let allPhasesCompleted = MissionPhase.allCases.allSatisfy { completedPhases.contains($0) }
        // Also check if AR game was completed
        let arGameCompleted = UserDefaults.standard.bool(forKey: "arGameCompleted")
        return allPhasesCompleted && arGameCompleted
    }
    
    func markMissionCompleted() {
        UserDefaults.standard.set(true, forKey: "missionCompleted")
        UserDefaults.standard.set(true, forKey: "arGameCompleted")
    }
}
