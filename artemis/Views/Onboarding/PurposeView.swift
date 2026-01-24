//
//  PurposeView.swift
//  artemis
//
//  Step 4: Why Artemis Matters - explain mission significance
//

import SwiftUI
import RealityKit

struct PurposeView: View {
    let onContinue: () -> Void
    let reduceMotion: Bool
    
    @State private var currentMessageIndex = 0
    @State private var trajectoryProgress: Float = 0
    
    private let messages = [
        "Artemis is how we learn to live beyond Earth.",
        "How we prepare for Mars.",
        "And how we go farther than ever before."
    ]
    
    var body: some View {
        ZStack {
            // Space background with trajectory
            PurposeBackgroundView(trajectoryProgress: trajectoryProgress)
            
            // Text overlay
            VStack {
                Spacer()
                
                if currentMessageIndex < messages.count {
                    Text(messages[currentMessageIndex])
                        .font(.system(size: 26, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .accessibilityLabel(messages[currentMessageIndex])
                }
                
                Spacer().frame(height: 100)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            handleTap()
        }
        .onAppear {
            // Animate trajectory (skip if Reduce Motion is enabled)
            if reduceMotion {
                trajectoryProgress = 1.0
            } else {
                withAnimation(.linear(duration: 3.0)) {
                    trajectoryProgress = 1.0
                }
            }
        }
    }
    
    private func handleTap() {
        if currentMessageIndex < messages.count - 1 {
            withAnimation(.easeInOut(duration: 0.5)) {
                currentMessageIndex += 1
            }
        } else {
            onContinue()
        }
    }
}

/// Space background with Earth → Moon trajectory animation
struct PurposeBackgroundView: UIViewRepresentable {
    let trajectoryProgress: Float
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.backgroundColor = .black
        arView.environment.background = .color(.black)
        arView.cameraMode = .nonAR
        
        // Create anchor
        let anchor = AnchorEntity()
        arView.scene.addAnchor(anchor)
        
        // Setup scene with starfield
        context.coordinator.setupScene(anchor: anchor)
        
        // Create Earth
        let earthMesh = MeshResource.generateSphere(radius: 0.5)
        let earthMaterial = SimpleMaterial(
            color: UIColor(red: 0.2, green: 0.5, blue: 0.9, alpha: 1.0),
            roughness: 0.7,
            isMetallic: false
        )
        let earth = ModelEntity(mesh: earthMesh, materials: [earthMaterial])
        earth.position = [-2, 0, -3]
        anchor.addChild(earth)
        
        // Add atmosphere glow around Earth
        let atmosphereMesh = MeshResource.generateSphere(radius: 0.52)
        let atmosphereMaterial = SimpleMaterial(
            color: UIColor(red: 0.3, green: 0.6, blue: 1.0, alpha: 0.3),
            roughness: 0.0,
            isMetallic: false
        )
        let atmosphere = ModelEntity(mesh: atmosphereMesh, materials: [atmosphereMaterial])
        atmosphere.position = [-2, 0, -3]
        anchor.addChild(atmosphere)
        
        // Create Moon
        let moonMesh = MeshResource.generateSphere(radius: 0.2)
        let moonMaterial = SimpleMaterial(
            color: UIColor(white: 0.8, alpha: 1.0),
            roughness: 0.9,
            isMetallic: false
        )
        let moon = ModelEntity(mesh: moonMesh, materials: [moonMaterial])
        moon.position = [2, 0, -3]
        anchor.addChild(moon)
        
        // Store references
        context.coordinator.earth = earth
        context.coordinator.moon = moon
        context.coordinator.anchor = anchor
        
        // Set up camera
        let camera = PerspectiveCamera()
        camera.position = [0, 0, 0]
        camera.look(at: [0, 0, -3], from: camera.position, relativeTo: nil)
        anchor.addChild(camera)
        
        // Add lighting
        let sunLight = DirectionalLight()
        sunLight.light.intensity = 2000
        sunLight.position = [0, 2, -2]
        anchor.addChild(sunLight)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Animate trajectory line
        context.coordinator.updateTrajectory(progress: trajectoryProgress)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var earth: ModelEntity?
        var moon: ModelEntity?
        var anchor: AnchorEntity?
        var trajectoryLine: ModelEntity?
        var starfield: [PointLight] = []
        
        func setupScene(anchor: AnchorEntity) {
            // Create starfield with point lights
            for _ in 0..<100 {
                let star = PointLight()
                star.light.intensity = Float.random(in: 20...100)
                star.position = [
                    Float.random(in: -10...10),
                    Float.random(in: -10...10),
                    Float.random(in: (-8)...(-2))
                ]
                anchor.addChild(star)
                starfield.append(star)
            }
        }
        
        func updateTrajectory(progress: Float) {
            guard let earth = earth, let moon = moon, let anchor = anchor else { return }
            
            // Remove existing line
            trajectoryLine?.removeFromParent()
            
            // Create trajectory line from Earth to Moon
            let earthPos = earth.position
            let moonPos = moon.position
            let endPos = earthPos + (moonPos - earthPos) * progress
            
            // Create line segment
            let lineLength = simd_length(endPos - earthPos)
            let direction = simd_normalize(endPos - earthPos)
            let midPoint = earthPos + direction * (lineLength / 2)
            
            let lineMesh = MeshResource.generateBox(size: [0.02, 0.02, lineLength])
            let lineMaterial = SimpleMaterial(
                color: UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 0.8),
                roughness: 0.0,
                isMetallic: false
            )
            let line = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
            line.position = midPoint
            line.look(at: endPos, from: midPoint, relativeTo: nil)
            
            anchor.addChild(line)
            trajectoryLine = line
        }
    }
}
