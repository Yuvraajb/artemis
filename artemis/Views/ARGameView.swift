//
//  ARGameView.swift
//  artemis
//
//  Main SwiftUI view for AR Rocket Launch Game
//

import SwiftUI
import RealityKit

struct ARGameView: View {
    @StateObject private var gameState = ARGameState()
    @State private var showCompletionOptions = false
    let onComplete: () -> Void
    
    var body: some View {
        ZStack {
            // AR View
            ARGameARView(gameState: gameState, onComplete: onComplete)
            
            // Moon Direction Arrows (only show when finding moon)
            if gameState.moonEntity != nil && !gameState.moonFound && gameState.phase == .findingMoon {
                MoonArrowIndicators(direction: gameState.moonDirection)
            }
            
            // HUD Overlay
            VStack {
                // Top HUD
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AR Launch")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        // Systems status
                        if gameState.phase != .placing {
                            HStack(spacing: 8) {
                                ForEach(gameState.systems) { system in
                                    Circle()
                                        .fill(system.isOperational ? Color.green : Color.gray)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Fuel gauge
                    if gameState.phase != .placing {
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Fuel")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 100, height: 8)
                                
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(gameState.fuelComplete ? Color.green : Color.orange)
                                    .frame(width: CGFloat(gameState.fuelLevel), height: 8)
                            }
                            
                            Text("\(Int(gameState.fuelLevel))%")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.7))
                )
                .padding()
                
                Spacer()
                
                // Instructions and countdown
                VStack(spacing: 12) {
                    if gameState.isLaunching && gameState.countdown > 0 {
                        Text("\(gameState.countdown)")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                Circle()
                                    .fill(Color.red.opacity(0.9))
                            )
                    } else {
                        switch gameState.phase {
                        case .findingMoon:
                            if gameState.moonEntity != nil && !gameState.moonFound {
                                VStack(spacing: 12) {
                                    Text("Find the Moon! 🌙")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("Follow the arrows to locate the Moon")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Tap the Moon when you find it")
                                        .font(.caption)
                                        .foregroundColor(.yellow)
                                        .fontWeight(.semibold)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.indigo.opacity(0.9))
                                )
                            } else if gameState.moonFound {
                                VStack(spacing: 12) {
                                    Text("Moon Found! ✓")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("Now place your launch pad")
                                        .font(.body)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.9))
                                )
                            }
                            
                        case .placing:
                            VStack(spacing: 12) {
                                Text("Place Launch Pad Below Moon")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Tap on the green target circle below the moon")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                
                                Text("Look for the blue guide line pointing down")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                    .italic()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.blue.opacity(0.9))
                            )
                            
                        case .systemsCheck:
                            if gameState.systemsChecked {
                                Text("All systems operational! ✓")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green.opacity(0.8))
                                    )
                            } else {
                                Text("Tap SYSTEMS button to check systems")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue.opacity(0.8))
                                    )
                            }
                            
                        case .fueling:
                            if gameState.fuelComplete {
                                Text("Fuel tank full! ✓")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.green.opacity(0.8))
                                    )
                            } else {
                                Text("Tap FUEL button to fill the tank")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.orange.opacity(0.8))
                                    )
                            }
                            
                        case .ready:
                            Text("Ready to launch! Tap LAUNCH button")
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.8))
                                )
                            
                        case .launching:
                            Text("Launching...")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.8))
                                )
                            
                        case .launched:
                            Text("Rocket launched toward Moon! 🚀")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.orange.opacity(0.9))
                                )
                            
                            
                        case .completed:
                            if !showCompletionOptions {
                                VStack(spacing: 16) {
                                    Text("Mission Complete! 🎉")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                    
                                    Text("Rocket successfully reached the Moon!")
                                        .font(.body)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                    
                                    // Show options after a brief delay
                                    Button(action: {
                                        showCompletionOptions = true
                                    }) {
                                        Text("Continue")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 32)
                                            .padding(.vertical, 12)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.blue.opacity(0.8))
                                            )
                                    }
                                    .padding(.top, 8)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.green.opacity(0.9))
                                )
                            } else {
                                VStack(spacing: 16) {
                                    Text("Mission Complete! 🎉")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    // Action buttons
                                    VStack(spacing: 12) {
                                        Button(action: {
                                            // Restart mission
                                            gameState.reset()
                                            showCompletionOptions = false
                                        }) {
                                            HStack {
                                                Image(systemName: "arrow.clockwise")
                                                Text("Restart Mission")
                                            }
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(
                                                LinearGradient(
                                                    colors: [.blue, .purple],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .cornerRadius(12)
                                        }
                                        
                                        Button(action: {
                                            // Go back to home
                                            onComplete()
                                        }) {
                                            HStack {
                                                Image(systemName: "house.fill")
                                                Text("Back to Home")
                                            }
                                            .font(.subheadline)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(Color.gray.opacity(0.3))
                                            )
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.8))
                                )
                            }
                        }
                    }
                }
                .padding()
                
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            gameState.reset()
            showCompletionOptions = false
        }
    }
}

// Moon Arrow Indicators Component
struct MoonArrowIndicators: View {
    let direction: SIMD3<Float> // x = right/left, y = up/down
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Top arrow (if moon is above) - most common case
                if abs(direction.y) > abs(direction.x) && direction.y > 0.05 {
                    VStack {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.yellow)
                            .shadow(color: .black, radius: 8)
                        Text("Moon")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .shadow(color: .black, radius: 5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
                }
                
                // Bottom arrow (if moon is below)
                else if abs(direction.y) > abs(direction.x) && direction.y < -0.05 {
                    VStack {
                        Text("Moon")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .shadow(color: .black, radius: 5)
                        Image(systemName: "arrow.down")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.yellow)
                            .shadow(color: .black, radius: 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 40)
                }
                
                // Left arrow (if moon is to the left)
                else if abs(direction.x) > abs(direction.y) && direction.x < -0.05 {
                    HStack {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.yellow)
                            .shadow(color: .black, radius: 8)
                        Text("Moon")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .shadow(color: .black, radius: 5)
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.leading, 40)
                }
                
                // Right arrow (if moon is to the right)
                else if abs(direction.x) > abs(direction.y) && direction.x > 0.05 {
                    HStack {
                        Text("Moon")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .shadow(color: .black, radius: 5)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.yellow)
                            .shadow(color: .black, radius: 8)
                    }
                    .frame(maxHeight: .infinity)
                    .padding(.trailing, 40)
                }
            }
        }
    }
}
