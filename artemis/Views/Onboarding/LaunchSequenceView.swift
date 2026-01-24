//
//  LaunchSequenceView.swift
//  artemis
//
//  Step 6: SIGNATURE MOMENT - deliver emotional payoff
//

import SwiftUI
import RealityKit
import AVFoundation
import CoreHaptics

struct LaunchSequenceView: View {
    let onContinue: () -> Void
    let reduceMotion: Bool
    
    @State private var engineGlow: Float = 0.0
    @State private var cameraTilt: Float = 0.0
    @State private var screenShake: Float = 0.0
    @State private var showFlash = false
    @State private var showOrbitalView = false
    @State private var showFirstText = false
    @State private var showSecondText = false
    @State private var audioPlayer: AVAudioPlayer?
    @State private var hapticEngine: CHHapticEngine?
    
    var body: some View {
        ZStack {
            if showOrbitalView {
                // Orbital Earth view
                OrbitalEarthView()
                    .transition(.opacity)
            } else {
                // Launch sequence
                LaunchSequence3DView(
                    engineGlow: engineGlow,
                    cameraTilt: cameraTilt,
                    screenShake: screenShake
                )
            }
            
            // Flash overlay
            if showFlash {
                Color.white
                    .ignoresSafeArea()
                    .transition(.opacity)
            }
            
            // Text overlay (Frame 10: Center, no UI initially)
            if showOrbitalView {
                VStack(spacing: 20) {
                    if showFirstText {
                        Text("You've just launched Artemis.")
                            .font(.system(size: 28, weight: .light, design: .rounded))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                            .accessibilityLabel("You've just launched Artemis.")
                    }
                    
                    if showSecondText {
                        Text("Now explore how it works.")
                            .font(.system(size: 24, weight: .light, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .transition(.opacity)
                            .accessibilityLabel("Now explore how it works.")
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .onAppear {
            startLaunchSequence()
        }
    }
    
    private func startLaunchSequence() {
        setupHaptics()
        setupAudio()
        
        if reduceMotion {
            // Simplified sequence for Reduce Motion
            engineGlow = 1.0
            cameraTilt = -0.3
            showFlash = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showFlash = false
                showOrbitalView = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                showFirstText = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                showSecondText = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                onContinue()
            }
        } else {
            // Full sequence timing
            // 1. Engine glow intensifies (0-1s)
            withAnimation(.easeIn(duration: 1.0)) {
                engineGlow = 1.0
            }
            
            // 2. Camera tilts upward (1-2s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    cameraTilt = -0.3
                }
            }
            
            // 3. Screen shake and audio (2-3s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                startScreenShake()
                playLaunchAudio()
                playLaunchHaptics()
            }
            
            // 4. White flash (3s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeIn(duration: 0.1)) {
                    showFlash = true
                }
            }
            
            // 5. Full blackout (0.4s) - Frame 09 requirement
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
                withAnimation(.easeOut(duration: 0.1)) {
                    showFlash = false
                }
            }
            
            // 6. Orbital view fades in after blackout (3.5s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                withAnimation(.easeIn(duration: 1.0)) {
                    showOrbitalView = true
                }
            }
            
            // 7. Show first text after orbital view (5.5s) - Frame 10
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                withAnimation(.easeIn(duration: 1.0)) {
                    showFirstText = true
                }
            }
            
            // 8. Pause, then show second text (7.5s) - Frame 10
            DispatchQueue.main.asyncAfter(deadline: .now() + 7.5) {
                withAnimation(.easeIn(duration: 1.0)) {
                    showSecondText = true
                }
            }
            
            // 9. Continue to next frame after text (9.5s)
            DispatchQueue.main.asyncAfter(deadline: .now() + 9.5) {
                onContinue()
            }
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
    
    private func playLaunchHaptics() {
        guard let engine = hapticEngine else { return }
        
        do {
            // Intense rumble pattern
            var events: [CHHapticEvent] = []
            
            for i in 0..<10 {
                let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
                let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
                
                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [intensity, sharpness],
                    relativeTime: Double(i) * 0.1
                )
                events.append(event)
            }
            
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play launch haptics: \(error)")
        }
    }
    
    private func startScreenShake() {
        // Create subtle screen shake effect using rapid oscillations
        var shakeCount = 0
        let maxShakes = 20
        let shakeTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            shakeCount += 1
            if shakeCount >= maxShakes {
                timer.invalidate()
                self.screenShake = 0.0
            } else {
                // Alternate shake direction
                self.screenShake = (shakeCount % 2 == 0) ? 0.02 : -0.02
            }
        }
        RunLoop.main.add(shakeTimer, forMode: .common)
    }
    
    private func setupAudio() {
        // Create deep rumble audio programmatically
        // In a real implementation, you'd load an audio file
        // For now, we'll create a simple tone
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func playLaunchAudio() {
        // Generate a low-frequency rumble tone
        let sampleRate: Double = 44100
        let duration: Double = 1.0
        let frequency: Double = 60.0 // Low rumble
        
        let samples = Int(sampleRate * duration)
        var audioBuffer = [Float](repeating: 0, count: samples)
        
        for i in 0..<samples {
            let time = Double(i) / sampleRate
            audioBuffer[i] = Float(sin(2.0 * .pi * frequency * time) * 0.3)
        }
        
        // Create audio file and play
        // Note: This is simplified - in production, use a pre-recorded audio file
    }
}

/// 3D view for launch sequence
struct LaunchSequence3DView: UIViewRepresentable {
    let engineGlow: Float
    let cameraTilt: Float
    let screenShake: Float
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.backgroundColor = .black
        arView.environment.background = .color(.black)
        arView.cameraMode = .nonAR
        
        let anchor = AnchorEntity()
        arView.scene.addAnchor(anchor)
        
        // Setup scene with starfield and launch pad
        context.coordinator.setupScene(anchor: anchor)
        
        // Load SLS model
        context.coordinator.loadModel(anchor: anchor)
        
        // Set up camera
        let camera = PerspectiveCamera()
        context.coordinator.updateCamera(camera, tilt: cameraTilt, shake: screenShake)
        anchor.addChild(camera)
        context.coordinator.camera = camera
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let camera = context.coordinator.camera {
            context.coordinator.updateCamera(camera, tilt: cameraTilt, shake: screenShake)
        }
        
        // Update engine glow
        context.coordinator.updateEngineGlow(intensity: engineGlow)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var camera: PerspectiveCamera?
        var mainLight: DirectionalLight?
        var modelEntity: ModelEntity?
        var starfield: [PointLight] = []
        var launchPad: ModelEntity?
        var engineLight: PointLight?
        
        func setupScene(anchor: AnchorEntity) {
            // Create starfield
            for _ in 0..<80 {
                let star = PointLight()
                star.light.intensity = Float.random(in: 30...150)
                star.position = [
                    Float.random(in: -8...8),
                    Float.random(in: -8...8),
                    Float.random(in: (-10)...(-3))
                ]
                anchor.addChild(star)
                starfield.append(star)
            }
            
            // Create launch pad
            let padMesh = MeshResource.generateBox(size: [2.0, 0.1, 2.0])
            let padMaterial = SimpleMaterial(
                color: .darkGray,
                roughness: 0.8,
                isMetallic: false
            )
            let pad = ModelEntity(mesh: padMesh, materials: [padMaterial])
            pad.position = [0, -1.5, -2]
            anchor.addChild(pad)
            launchPad = pad
            
            // Main directional light
            let main = DirectionalLight()
            main.light.intensity = 1500
            main.position = [2, 2, 2]
            anchor.addChild(main)
            mainLight = main
            
            // Engine glow light (will intensify during launch)
            let engine = PointLight()
            engine.light.intensity = 500
            engine.position = [0, -1, -2]
            engine.light.color = .init(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
            anchor.addChild(engine)
            engineLight = engine
        }
        
        func loadModel(anchor: AnchorEntity) {
            Task { @MainActor [weak self] in
                do {
                    let model = try await ModelEntity(named: "sls.usdz")
                    self?.modelEntity = model
                    
                    let bounds = model.visualBounds(relativeTo: nil)
                    let center = bounds.center
                    model.position = [0, -center.y, -2] - [0, 0, 0]
                    
                    anchor.addChild(model)
                } catch {
                    print("Failed to load SLS model: \(error)")
                }
            }
        }
        
        func updateCamera(_ camera: PerspectiveCamera, tilt: Float, shake: Float) {
            // Apply shake offset (will be animated by SwiftUI)
            let baseY: Float = 1.0 + tilt
            let shakeOffset = shake > 0 ? shake * 0.5 : 0
            
            camera.position = [shakeOffset, baseY + shakeOffset, 2.0]
            camera.look(at: [0, 0, -2], from: camera.position, relativeTo: nil)
        }
        
        func updateEngineGlow(intensity: Float) {
            // Update engine light intensity
            if let light = engineLight {
                light.light.intensity = 500 + (intensity * 2000)
            }
        }
    }
}

/// Orbital Earth view after launch
struct OrbitalEarthView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.backgroundColor = .black
        arView.environment.background = .color(.black)
        arView.cameraMode = .nonAR
        
        let anchor = AnchorEntity()
        arView.scene.addAnchor(anchor)
        
        // Add starfield
        context.coordinator.setupStarfield(anchor: anchor)
        
        // Create Earth
        let earthMesh = MeshResource.generateSphere(radius: 1.5)
        let earthMaterial = SimpleMaterial(
            color: UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0),
            roughness: 0.8,
            isMetallic: false
        )
        let earth = ModelEntity(mesh: earthMesh, materials: [earthMaterial])
        earth.position = [0, 0, -4]
        anchor.addChild(earth)
        
        // Add atmosphere
        let atmosphereMesh = MeshResource.generateSphere(radius: 1.52)
        let atmosphereMaterial = SimpleMaterial(
            color: UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.4),
            roughness: 0.0,
            isMetallic: false
        )
        let atmosphere = ModelEntity(mesh: atmosphereMesh, materials: [atmosphereMaterial])
        atmosphere.position = [0, 0, -4]
        anchor.addChild(atmosphere)
        
        // Camera positioned in orbit
        let camera = PerspectiveCamera()
        camera.position = [0, 0, 0]
        camera.look(at: [0, 0, -4], from: camera.position, relativeTo: nil)
        anchor.addChild(camera)
        
        // Store earth reference for rotation
        context.coordinator.earth = earth
        
        // Rotate Earth slowly
        Task { @MainActor in
            var rotation: Float = 0
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                rotation += 0.01
                earth.orientation = simd_quatf(angle: rotation, axis: [0, 1, 0])
            }
        }
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var earth: ModelEntity?
        var starfield: [PointLight] = []
        
        func setupStarfield(anchor: AnchorEntity) {
            for _ in 0..<120 {
                let star = PointLight()
                star.light.intensity = Float.random(in: 40...180)
                star.position = [
                    Float.random(in: -15...15),
                    Float.random(in: -15...15),
                    Float.random(in: (-10)...(-5))
                ]
                anchor.addChild(star)
                starfield.append(star)
            }
        }
    }
}
