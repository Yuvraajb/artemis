//
//  GameViewModel.swift
//  artemis
//
//  Game logic and state management for Mission Simulation
//

import Foundation
import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    @Published var gameState = GameState()
    
    private var gameTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // Game configuration
    private let timeScale: Double = 60.0 // 1 real second = 60 game seconds
    private let fuelConsumptionRate: Double = 0.1 // % per second during active phases
    
    init() {
        setupObservers()
    }
    
    private func setupObservers() {
        // Update efficiency when fuel or trajectory changes
        gameState.$fuelUsed
            .combineLatest(gameState.$trajectoryAccuracy)
            .sink { [weak self] _, _ in
                self?.gameState.calculateEfficiency()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Phase Management
    
    func startMission() {
        gameState.isMissionActive = true
        gameState.currentPhase = .launch
        startGameTimer()
    }
    
    func advanceToNextPhase() {
        guard let currentIndex = GamePhase.allCases.firstIndex(of: gameState.currentPhase),
              currentIndex < GamePhase.allCases.count - 1 else {
            endMission()
            return
        }
        
        let nextPhase = GamePhase.allCases[currentIndex + 1]
        gameState.currentPhase = nextPhase
        
        // Phase-specific initialization
        initializePhase(nextPhase)
    }
    
    private func initializePhase(_ phase: GamePhase) {
        switch phase {
        case .launch:
            gameState.altitude = 0.0
            gameState.velocity = 0.0
            gameState.fuel = 100.0
        case .orbit:
            gameState.altitude = 400.0 // Low Earth Orbit
            gameState.velocity = OrbitalPhysics.orbitalVelocity(atAltitude: 400.0)
        case .lunarApproach:
            gameState.altitude = 1000.0
            gameState.velocity = 10.5 // Trans-lunar injection velocity
        case .returnJourney:
            gameState.distanceToMoon = 100000.0 // On return trajectory
            gameState.velocity = 10.0
        case .reentry:
            gameState.altitude = 120.0 // Re-entry altitude
            gameState.velocity = 11.0 // Re-entry velocity
        default:
            break
        }
    }
    
    func endMission() {
        gameState.isMissionActive = false
        stopGameTimer()
        gameState.currentPhase = .debrief
        gameState.calculateEfficiency()
    }
    
    // MARK: - Game Timer
    
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateGameState()
        }
    }
    
    private func stopGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
    
    private func updateGameState() {
        guard gameState.isMissionActive else { return }
        
        // Update mission time
        gameState.missionTime += 0.1 * timeScale
        
        // Phase-specific updates
        switch gameState.currentPhase {
        case .launch:
            updateLaunchPhase()
        case .orbit:
            updateOrbitPhase()
        case .lunarApproach:
            updateLunarApproachPhase()
        case .returnJourney:
            updateReturnJourneyPhase()
        case .reentry:
            updateReentryPhase()
        default:
            break
        }
    }
    
    // MARK: - Phase Updates
    
    private func updateLaunchPhase() {
        // Increase altitude and velocity during launch
        if gameState.altitude < 400 {
            gameState.altitude += 0.5
            gameState.velocity = min(gameState.velocity + 0.02, OrbitalPhysics.orbitalVelocityLEO)
            consumeFuel(rate: fuelConsumptionRate * 2) // Higher consumption during launch
        } else {
            // Reached orbit
            advanceToNextPhase()
        }
    }
    
    private func updateOrbitPhase() {
        // Maintain orbit, slight fuel consumption
        consumeFuel(rate: fuelConsumptionRate * 0.1)
        
        // Auto-advance after systems check (simplified)
        if gameState.missionTime > 30 {
            advanceToNextPhase()
        }
    }
    
    private func updateLunarApproachPhase() {
        // Approach Moon
        if gameState.distanceToMoon > 1000 {
            gameState.distanceToMoon -= 50
            gameState.altitude += 10
            consumeFuel(rate: fuelConsumptionRate * 0.5)
        } else {
            // Reached Moon
            advanceToNextPhase()
        }
    }
    
    private func updateReturnJourneyPhase() {
        // Return to Earth
        if gameState.distanceToMoon < OrbitalPhysics.moonDistance {
            gameState.distanceToMoon += 30
            gameState.altitude -= 5
            consumeFuel(rate: fuelConsumptionRate * 0.3)
        } else {
            // Approaching Earth
            advanceToNextPhase()
        }
    }
    
    private func updateReentryPhase() {
        // Descend through atmosphere
        if gameState.altitude > 0 {
            gameState.altitude -= 0.2
            gameState.velocity = max(gameState.velocity - 0.1, 0.0)
        } else {
            // Splashdown
            endMission()
        }
    }
    
    // MARK: - Fuel Management
    
    private func consumeFuel(rate: Double) {
        let consumption = rate * 0.1 // Per timer tick
        gameState.fuel = max(0, gameState.fuel - consumption)
        gameState.fuelUsed += consumption
        
        // Check for fuel depletion
        if gameState.fuel <= 0 {
            handleFuelDepletion()
        }
    }
    
    private func handleFuelDepletion() {
        // Mission failure due to fuel
        gameState.updateScore(points: -50)
        endMission()
    }
    
    // MARK: - Decision Handling
    
    func makeDecision(phase: GamePhase, question: String, choice: String, isCorrect: Bool) {
        let decision = GameDecision(
            phase: phase,
            question: question,
            choice: choice,
            wasCorrect: isCorrect
        )
        
        gameState.recordDecision(decision)
        
        if isCorrect {
            gameState.updateScore(points: 20)
            applyCorrectDecisionEffects(phase: phase)
        } else {
            gameState.updateScore(points: -10)
            applyIncorrectDecisionEffects(phase: phase)
        }
    }
    
    private func applyCorrectDecisionEffects(phase: GamePhase) {
        switch phase {
        case .launch:
            // Efficient fuel allocation
            gameState.fuel += 5
        case .orbit:
            // Optimal trajectory burn
            gameState.trajectoryAccuracy = min(100, gameState.trajectoryAccuracy + 5)
        case .lunarApproach:
            // Good course correction
            gameState.trajectoryAccuracy = min(100, gameState.trajectoryAccuracy + 3)
        case .reentry:
            // Safe re-entry angle
            gameState.trajectoryAccuracy = min(100, gameState.trajectoryAccuracy + 10)
        default:
            break
        }
    }
    
    private func applyIncorrectDecisionEffects(phase: GamePhase) {
        switch phase {
        case .launch:
            // Inefficient fuel use
            consumeFuel(rate: fuelConsumptionRate * 2)
        case .orbit:
            // Poor trajectory
            gameState.trajectoryAccuracy = max(0, gameState.trajectoryAccuracy - 10)
        case .lunarApproach:
            // Course correction needed
            gameState.trajectoryAccuracy = max(0, gameState.trajectoryAccuracy - 5)
        case .reentry:
            // Dangerous re-entry
            gameState.trajectoryAccuracy = max(0, gameState.trajectoryAccuracy - 15)
        default:
            break
        }
    }
    
    // MARK: - Trajectory Calculations
    
    func getTrajectoryPoints() -> [CGPoint] {
        return OrbitalPhysics.calculateTrajectory(
            currentAltitude: gameState.altitude,
            currentVelocity: gameState.velocity,
            targetDistance: gameState.distanceToMoon
        )
    }
    
    // MARK: - System Checks
    
    func performSystemCheck() -> Bool {
        // Check all systems
        let allSystemsOperational = gameState.systemsStatus.values.allSatisfy { $0 }
        
        if allSystemsOperational {
            gameState.updateScore(points: 10)
            return true
        } else {
            gameState.updateScore(points: -20)
            return false
        }
    }
    
    func resetGame() {
        stopGameTimer()
        gameState.reset()
    }
    
    deinit {
        stopGameTimer()
    }
}
