//
//  GameHUD.swift
//  artemis
//
//  Heads-up display overlay for mission simulation game
//

import SwiftUI

struct GameHUD: View {
    @ObservedObject var gameState: GameState
    
    var body: some View {
        VStack {
            // Top HUD
            HStack {
                // Mission phase indicator
                VStack(alignment: .leading, spacing: 4) {
                    Text(gameState.currentPhase.displayName)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Mission Time: \(formatTime(gameState.missionTime))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Score with animation
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Score")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(gameState.score)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.cyan)
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: gameState.score)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.7))
            )
            .padding()
            
            Spacer()
            
            // Bottom metrics
            HStack(spacing: 20) {
                // Fuel gauge
                MetricGauge(
                    label: "Fuel",
                    value: gameState.fuel,
                    color: gameState.fuel > 30 ? .green : (gameState.fuel > 10 ? .orange : .red),
                    unit: "%"
                )
                
                // Altitude
                MetricDisplay(
                    label: "Altitude",
                    value: gameState.altitude,
                    unit: "km",
                    color: .blue
                )
                
                // Velocity
                MetricDisplay(
                    label: "Velocity",
                    value: gameState.velocity,
                    unit: "km/s",
                    color: .purple
                )
                
                // Distance to Moon (if applicable)
                if gameState.currentPhase == .lunarApproach || gameState.currentPhase == .returnJourney {
                    MetricDisplay(
                        label: "Moon Distance",
                        value: gameState.distanceToMoon,
                        unit: "km",
                        color: .indigo
                    )
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.7))
            )
            .padding()
        }
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
}

struct MetricGauge: View {
    let label: String
    let value: Double
    let color: Color
    let unit: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 60, height: 60)
                
                Circle()
                    .trim(from: 0, to: value / 100)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.3), value: value)
                
                VStack(spacing: 0) {
                    Text("\(Int(value))")
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(unit)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

struct MetricDisplay: View {
    let label: String
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text(formatValue(value))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text(unit)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func formatValue(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1f", value / 1000) + "k"
        } else if value >= 100 {
            return String(format: "%.0f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        GameHUD(gameState: GameState())
    }
}
