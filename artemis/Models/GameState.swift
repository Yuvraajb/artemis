//
//  GameState.swift
//  artemis
//
//  Game state management for Mission Simulation Game
//

import Foundation
import SwiftUI
import Combine

/// Mission phases within the simulation game
enum GamePhase: String, CaseIterable, Identifiable {
    case introduction = "introduction"
    case launch = "launch"
    case orbit = "orbit"
    case lunarApproach = "lunar_approach"
    case returnJourney = "return_journey"
    case reentry = "reentry"
    case debrief = "debrief"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .introduction: return "Mission Briefing"
        case .launch: return "Launch"
        case .orbit: return "Earth Orbit"
        case .lunarApproach: return "Lunar Approach"
        case .returnJourney: return "Return Journey"
        case .reentry: return "Re-entry"
        case .debrief: return "Mission Debrief"
        }
    }
}

/// Tracks game state and metrics
class GameState: ObservableObject {
    @Published var currentPhase: GamePhase = .introduction
    @Published var fuel: Double = 100.0 // Percentage
    @Published var altitude: Double = 0.0 // Kilometers
    @Published var velocity: Double = 0.0 // km/s
    @Published var distanceToMoon: Double = 384400.0 // Kilometers (Earth-Moon distance)
    @Published var missionTime: Double = 0.0 // Seconds
    @Published var isMissionActive: Bool = false
    
    // Decision tracking
    @Published var decisions: [GameDecision] = []
    @Published var score: Int = 0
    @Published var efficiency: Double = 100.0 // Percentage
    
    // Performance metrics
    @Published var fuelUsed: Double = 0.0
    @Published var trajectoryAccuracy: Double = 100.0
    @Published var systemsStatus: [String: Bool] = [
        "lifeSupport": true,
        "power": true,
        "communication": true,
        "navigation": true
    ]
    
    func reset() {
        currentPhase = .introduction
        fuel = 100.0
        altitude = 0.0
        velocity = 0.0
        distanceToMoon = 384400.0
        missionTime = 0.0
        isMissionActive = false
        decisions = []
        score = 0
        efficiency = 100.0
        fuelUsed = 0.0
        trajectoryAccuracy = 100.0
        systemsStatus = [
            "lifeSupport": true,
            "power": true,
            "communication": true,
            "navigation": true
        ]
    }
    
    func recordDecision(_ decision: GameDecision) {
        decisions.append(decision)
    }
    
    func updateScore(points: Int) {
        score += points
    }
    
    func calculateEfficiency() {
        // Efficiency based on fuel usage and trajectory accuracy
        let fuelEfficiency = max(0, 100 - (fuelUsed * 2))
        efficiency = (fuelEfficiency + trajectoryAccuracy) / 2
    }
}

/// Represents a decision made during gameplay
struct GameDecision: Identifiable {
    let id: UUID
    let phase: GamePhase
    let question: String
    let choice: String
    let wasCorrect: Bool
    let timestamp: Date
    
    init(phase: GamePhase, question: String, choice: String, wasCorrect: Bool) {
        self.id = UUID()
        self.phase = phase
        self.question = question
        self.choice = choice
        self.wasCorrect = wasCorrect
        self.timestamp = Date()
    }
}
