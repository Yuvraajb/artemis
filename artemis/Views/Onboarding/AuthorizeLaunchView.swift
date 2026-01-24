//
//  AuthorizeLaunchView.swift
//  artemis
//
//  Step 5: Commitment - force intentional user action
//

import SwiftUI
import RealityKit
import CoreHaptics

struct AuthorizeLaunchView: View {
    let onContinue: () -> Void
    
    @State private var holdProgress: Double = 0.0
    @State private var isHolding = false
    @State private var hapticEngine: CHHapticEngine?
    
    private let holdDuration: TimeInterval = 2.0
    
    var body: some View {
        ZStack {
            // SLS on launch pad (darker than before)
            LaunchPadView()
                .opacity(0.5)
            
            // Darkened overlay (more than before)
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            // Text and Button - Frame 07
            VStack(spacing: 40) {
                Spacer()
                
                // Frame 07: "This mission requires intention."
                VStack(spacing: 12) {
                    Text("This mission requires intention.")
                        .font(.system(size: 24, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    Text("Authorize launch.")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.bottom, 40)
                
                // Frame 08: Press & Hold Button
                Button(action: {}) {
                    ZStack {
                        // Progress fill
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 280, height: 60)
                        
                        // Progress indicator
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .frame(width: geometry.size.width * holdProgress, height: 60)
                                .animation(.linear(duration: 0.1), value: holdProgress)
                        }
                        .frame(width: 280, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        // Text
                        Text("AUTHORIZE LAUNCH")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            if !isHolding {
                                startHold()
                            }
                        }
                        .onEnded { _ in
                            stopHold()
                        }
                )
                .accessibilityLabel("Authorize Launch. Press and hold to authorize.")
                .accessibilityHint("Hold for 2 seconds to authorize the launch.")
                
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            setupHaptics()
        }
    }
    
    private func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            let engine = try CHHapticEngine()
            try engine.start()
            hapticEngine = engine
        } catch {
            print("Failed to start haptic engine: \(error)")
        }
    }
    
    private func startHold() {
        isHolding = true
        holdProgress = 0.0
        
        // Start haptic feedback
        playHapticPattern()
        
        // Animate progress
        withAnimation(.linear(duration: holdDuration)) {
            holdProgress = 1.0
        }
        
        // Complete after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
            if isHolding {
                completeHold()
            }
        }
    }
    
    private func stopHold() {
        isHolding = false
        withAnimation {
            holdProgress = 0.0
        }
    }
    
    private func completeHold() {
        isHolding = false
        onContinue()
    }
    
    private func playHapticPattern() {
        guard let engine = hapticEngine else { return }
        
        do {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.5)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [intensity, sharpness],
                relativeTime: 0,
                duration: holdDuration
            )
            
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
}

/// SLS on launch pad visualization
struct LaunchPadView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.backgroundColor = .black
        arView.environment.background = .color(.black)
        arView.cameraMode = .nonAR
        
        // Create anchor
        let anchor = AnchorEntity()
        arView.scene.addAnchor(anchor)
        
        // Load SLS model
        context.coordinator.loadModel(anchor: anchor)
        
        // Set up camera (side view of launch pad)
        let camera = PerspectiveCamera()
        camera.position = [3, 1, 2]
        camera.look(at: [0, 0, -2], from: camera.position, relativeTo: nil)
        anchor.addChild(camera)
        
        // Dim lighting
        let light = DirectionalLight()
        light.light.intensity = 500
        light.position = [2, 2, 2]
        anchor.addChild(light)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        func loadModel(anchor: AnchorEntity) {
            Task { @MainActor in
                do {
                    let model = try await ModelEntity(named: "sls.usdz")
                    let bounds = model.visualBounds(relativeTo: nil)
                    let center = bounds.center
                    model.position = [0, -center.y, -2] - [0, 0, 0]
                    anchor.addChild(model)
                } catch {
                    print("Failed to load SLS model: \(error)")
                    // Create placeholder
                    let mesh = MeshResource.generateBox(size: [0.3, 2.0, 0.3])
                    let material = SimpleMaterial(color: .white, roughness: 0.3, isMetallic: true)
                    let placeholder = ModelEntity(mesh: mesh, materials: [material])
                    placeholder.position = [0, 0, -2]
                    anchor.addChild(placeholder)
                }
            }
        }
    }
}
