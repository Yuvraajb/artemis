//
//  OrbitalPhysics.swift
//  artemis
//
//  Simplified orbital mechanics calculations for game simulation
//

import Foundation
import SwiftUI

/// Simplified orbital physics engine for educational gameplay
struct OrbitalPhysics {
    // Constants
    static let earthRadius: Double = 6371.0 // km
    static let moonDistance: Double = 384400.0 // km (average)
    static let earthGravity: Double = 9.81 // m/s²
    static let orbitalVelocityLEO: Double = 7.8 // km/s (Low Earth Orbit)
    static let escapeVelocity: Double = 11.2 // km/s
    
    /// Calculate orbital velocity at given altitude
    static func orbitalVelocity(atAltitude altitude: Double) -> Double {
        // Simplified: v = sqrt(GM / r)
        // Using approximation for educational purposes
        let radius = earthRadius + altitude
        if altitude < 2000 {
            // Low Earth Orbit
            return orbitalVelocityLEO * (1 - altitude / 2000 * 0.1)
        } else {
            // Higher orbits - simplified calculation
            return orbitalVelocityLEO * sqrt(earthRadius / radius)
        }
    }
    
    /// Calculate trajectory path points for visualization
    static func calculateTrajectory(
        currentAltitude: Double,
        currentVelocity: Double,
        targetDistance: Double,
        timeSteps: Int = 100
    ) -> [CGPoint] {
        var points: [CGPoint] = []
        let maxDistance = moonDistance * 1.5
        
        for i in 0..<timeSteps {
            let progress = Double(i) / Double(timeSteps)
            let distance = currentAltitude + (targetDistance - currentAltitude) * progress
            
            // Simplified elliptical trajectory
            let x = progress * maxDistance
            let y = distance / maxDistance * 200 // Scale for visualization
            
            points.append(CGPoint(x: x, y: y))
        }
        
        return points
    }
    
    /// Calculate fuel consumption for a burn
    static func fuelConsumption(
        deltaV: Double,
        currentMass: Double
    ) -> Double {
        // Simplified: fuel = deltaV / specificImpulse * mass
        // Using typical rocket values
        let specificImpulse = 450.0 // seconds (typical for chemical rockets)
        return (deltaV / specificImpulse) * currentMass * 0.01 // Convert to percentage
    }
    
    /// Check if trajectory will reach target
    static func willReachTarget(
        currentVelocity: Double,
        currentAltitude: Double,
        targetDistance: Double
    ) -> Bool {
        // Simplified check: velocity must be sufficient for Hohmann transfer
        let requiredVelocity = sqrt(2 * earthGravity * (targetDistance - currentAltitude) / 1000)
        return currentVelocity >= requiredVelocity * 0.8 // 80% threshold for gameplay
    }
    
    /// Calculate time to reach target
    static func timeToTarget(
        currentDistance: Double,
        targetDistance: Double,
        velocity: Double
    ) -> Double {
        // Simplified: time = distance / velocity
        let distance = abs(targetDistance - currentDistance)
        return distance / max(velocity, 0.1) // Avoid division by zero
    }
    
    /// Calculate re-entry angle for safe return
    static func safeReentryAngle(altitude: Double, velocity: Double) -> Double {
        // Optimal re-entry angle is between 6-7 degrees
        // Simplified calculation
        if velocity > 11.0 {
            return 6.5 // High velocity needs steeper angle
        } else {
            return 6.0 // Standard re-entry
        }
    }
    
    /// Check if re-entry angle is safe
    static func isReentryAngleSafe(angle: Double) -> Bool {
        // Safe range: 5.5 to 7.5 degrees
        return angle >= 5.5 && angle <= 7.5
    }
}

/// Represents a point in the mission trajectory
struct TrajectoryPoint {
    let time: Double
    let altitude: Double
    let velocity: Double
    let distanceToMoon: Double
    let position: CGPoint
}
