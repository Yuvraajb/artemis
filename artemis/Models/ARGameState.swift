//
//  ARGameState.swift
//  artemis
//
//  Game state for AR Rocket Launch Game
//

import Foundation
import SwiftUI
import Combine
import RealityKit

/// Game phase for AR launch game
enum ARGamePhase: String {
    case placing = "placing"
    case systemsCheck = "systems_check"
    case fueling = "fueling"
    case ready = "ready"
    case launching = "launching"
    case launched = "launched"
    case findingMoon = "finding_moon"
    case completed = "completed"
}

/// System status for launch readiness
struct SystemStatus: Identifiable {
    let id: String
    var isOperational: Bool = false
    let name: String
}

/// Game state for AR launch game
class ARGameState: ObservableObject {
    @Published var phase: ARGamePhase = .placing
    
    @Published var isRocketPlaced: Bool = false
    @Published var isRocketLaunched: Bool = false
    @Published var rocketEntity: ModelEntity?
    @Published var launchPadEntity: ModelEntity?
    @Published var moonEntity: ModelEntity?
    @Published var moonFound: Bool = false
    @Published var moonDirection: SIMD3<Float> = SIMD3<Float>(0, 0, 0) // Direction to moon from camera
    @Published var moonDistance: Float = 0.0
    @Published var placementGuideEntity: ModelEntity?
    @Published var placementTargetEntity: ModelEntity?
    
    // Launch pad buttons
    @Published var systemsCheckButton: ModelEntity?
    @Published var fuelButton: ModelEntity?
    @Published var launchButton: ModelEntity?
    
    // Systems check
    @Published var systems: [SystemStatus] = [
        SystemStatus(id: "lifeSupport", name: "Life Support"),
        SystemStatus(id: "power", name: "Power"),
        SystemStatus(id: "communication", name: "Communication"),
        SystemStatus(id: "navigation", name: "Navigation")
    ]
    @Published var systemsChecked: Bool = false
    @Published var currentSystemCheckIndex: Int = 0
    
    // Fuel
    @Published var fuelLevel: Double = 0.0 // 0-100
    @Published var isFueling: Bool = false
    @Published var fuelComplete: Bool = false
    
    // Launch
    @Published var countdown: Int = 0
    @Published var isLaunching: Bool = false
    
    var canLaunch: Bool {
        return systemsChecked && fuelComplete && !isLaunching
    }
    
    func reset() {
        phase = .findingMoon
        isRocketPlaced = false
        isRocketLaunched = false
        rocketEntity = nil
        launchPadEntity = nil
        systemsCheckButton = nil
        fuelButton = nil
        launchButton = nil
        systemsChecked = false
        currentSystemCheckIndex = 0
        fuelLevel = 0.0
        isFueling = false
        fuelComplete = false
        countdown = 0
        isLaunching = false
        moonEntity = nil
        moonFound = false
        moonDirection = SIMD3<Float>(0, 0, 0)
        moonDistance = 0.0
        
        // Reset systems
        for i in 0..<systems.count {
            systems[i].isOperational = false
        }
    }
    
    func checkNextSystem() {
        guard currentSystemCheckIndex < systems.count else {
            systemsChecked = true
            return
        }
        
        systems[currentSystemCheckIndex].isOperational = true
        currentSystemCheckIndex += 1
        
        if currentSystemCheckIndex >= systems.count {
            systemsChecked = true
        }
    }
    
    func addFuel(amount: Double = 10.0) {
        guard !fuelComplete else { return }
        fuelLevel = min(100.0, fuelLevel + amount)
        if fuelLevel >= 100.0 {
            fuelComplete = true
        }
    }
}
