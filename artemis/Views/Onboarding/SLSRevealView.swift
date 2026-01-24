//
//  SLSRevealView.swift
//  artemis
//
//  Step 2: Scale & Presence - communicate scale and seriousness
//

import SwiftUI
import RealityKit
import simd

struct SLSRevealView: View {
    let onContinue: () -> Void
    let reduceMotion: Bool
    
    @State private var cameraTilt: Float = 0.0
    @State private var cameraForward: Float = 0.0
    @State private var lightIntensity: Float = 0.0
    @State private var rocketOpacity: Float = 0.0
    @State private var hasRevealed = false
    
    var body: some View {
        ZStack {
            // Darkness below Earth
            Color.black.ignoresSafeArea()
            
            SLSReveal3DView(
                cameraTilt: cameraTilt,
                cameraForward: cameraForward,
                lightIntensity: lightIntensity,
                rocketOpacity: rocketOpacity,
                onSwipeUp: {
                    if !hasRevealed {
                        revealRocket()
                    }
                }
            )
            
            // Text Overlay (Bottom, Subtle)
            VStack {
                Spacer()
                Text("This is the most powerful rocket ever built.")
                    .font(.system(size: 18, weight: .light, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 60)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.height < -50 && !hasRevealed {
                        revealRocket()
                    }
                }
        )
        .onAppear {
            // Camera slowly tilts downward, SLS fades in from shadow
            if !reduceMotion {
                withAnimation(.easeIn(duration: 2.0)) {
                    cameraTilt = -0.2 // Tilt downward
                    cameraForward = 0.3 // Slight forward movement
                    lightIntensity = 600 // Ramp from 20% (200) to 60% (600) of max
                    rocketOpacity = 1.0
                }
            } else {
                cameraTilt = -0.2
                cameraForward = 0.3
                lightIntensity = 600
                rocketOpacity = 1.0
            }
        }
    }
    
    private func revealRocket() {
        hasRevealed = true
        
        if reduceMotion {
            cameraTilt = 0.0
            cameraForward = 0.0
            lightIntensity = 1500
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                onContinue()
            }
        } else {
            // Camera elevation increase, full rocket revealed
            withAnimation(.easeOut(duration: 2.5)) {
                cameraTilt = 0.0 // Return to level
                cameraForward = 0.0
            }
            
            // Ramp up lighting to full
            withAnimation(.easeIn(duration: 2.0)) {
                lightIntensity = 1500
            }
            
            // Advance after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                onContinue()
            }
        }
    }
}

/// RealityKit view for SLS reveal with camera animation
struct SLSReveal3DView: UIViewRepresentable {
    let cameraTilt: Float
    let cameraForward: Float
    let lightIntensity: Float
    let rocketOpacity: Float
    let onSwipeUp: () -> Void
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.backgroundColor = .black
        arView.environment.background = .color(.black)
        arView.cameraMode = .nonAR
        
        // Create anchor
        let anchor = AnchorEntity()
        arView.scene.addAnchor(anchor)
        
        // Setup scene with lighting
        context.coordinator.setupScene(anchor: anchor)
        
        // Load SLS model
        context.coordinator.loadModel(anchor: anchor)
        
        // Set up camera (low-angle perspective)
        let camera = PerspectiveCamera()
        context.coordinator.updateCamera(camera, tilt: cameraTilt, forward: cameraForward)
        anchor.addChild(camera)
        context.coordinator.camera = camera
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update camera position
        if let camera = context.coordinator.camera {
            context.coordinator.updateCamera(camera, tilt: cameraTilt, forward: cameraForward)
        }
        
        // Update main light intensity (ramps from 20% → 60% initially)
        if let light = context.coordinator.mainLight {
            light.light.intensity = lightIntensity
        }
        
        // Update rocket opacity (fades in from shadow)
        if let model = context.coordinator.modelEntity {
            model.isEnabled = rocketOpacity > 0.1
            // Update opacity through material if possible
            // For now, we'll use isEnabled to control visibility
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var camera: PerspectiveCamera?
        var mainLight: DirectionalLight?
        var modelEntity: ModelEntity?
        
        func setupScene(anchor: AnchorEntity) {
            // Add starfield for visual context
            for _ in 0..<60 {
                let star = PointLight()
                star.light.intensity = Float.random(in: 50...200)
                star.position = [
                    Float.random(in: -8...8),
                    Float.random(in: -3...8),
                    Float.random(in: -10...(-4))
                ]
                anchor.addChild(star)
            }
            
            // Single directional light (intensity ramps from 20% → 60%)
            let main = DirectionalLight()
            main.light.intensity = 200 // Start at 20% of max (1000)
            main.position = [2, 2, 2]
            anchor.addChild(main)
            mainLight = main
        }
        
        func loadModel(anchor: AnchorEntity) {
            Task { @MainActor [weak self] in
                do {
                    let model = try await ModelEntity(named: "sls.usdz")
                    self?.modelEntity = model
                    
                    // Center model on vertical axis
                    let bounds = model.visualBounds(relativeTo: nil)
                    let center = bounds.center
                    model.position = [0, -center.y, -2] - [0, 0, 0]
                    
                    anchor.addChild(model)
                } catch {
                    print("Failed to load SLS model: \(error)")
                    self?.createPlaceholder(anchor: anchor)
                }
            }
        }
        
        func updateCamera(_ camera: PerspectiveCamera, tilt: Float, forward: Float) {
            // Low-angle perspective with tilt and forward movement
            let baseY: Float = -1.0
            let baseZ: Float = 2.0
            camera.position = [0, baseY + tilt * 2, baseZ - forward]
            camera.look(at: [0, 0, -2], from: camera.position, relativeTo: nil)
        }
        
        private func createPlaceholder(anchor: AnchorEntity) {
            let mesh = MeshResource.generateBox(size: [0.3, 2.0, 0.3])
            let material = SimpleMaterial(color: .white, roughness: 0.3, isMetallic: true)
            let placeholder = ModelEntity(mesh: mesh, materials: [material])
            placeholder.position = [0, 0, -2]
            anchor.addChild(placeholder)
            modelEntity = placeholder
        }
    }
}
