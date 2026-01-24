//
//  SLSStillnessView.swift
//  artemis
//
//  Frame 03: Full SLS Reveal (Stillness) - Let the scale sit. Do nothing.
//

import SwiftUI
import RealityKit

struct SLSStillnessView: View {
    let onContinue: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            SLSStillness3DView()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onContinue()
        }
    }
}

/// Full SLS reveal with stillness - no motion except slight light shimmer
struct SLSStillness3DView: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.backgroundColor = .black
        arView.environment.background = .color(.black)
        arView.cameraMode = .nonAR
        
        let anchor = AnchorEntity()
        arView.scene.addAnchor(anchor)
        
        // Setup scene
        context.coordinator.setupScene(anchor: anchor)
        
        // Load SLS model
        context.coordinator.loadModel(anchor: anchor)
        
        // Set up camera (static, positioned to emphasize height)
        let camera = PerspectiveCamera()
        camera.position = [0, 2.0, 1.5]
        camera.look(at: [0, 0, -2], from: camera.position, relativeTo: nil)
        anchor.addChild(camera)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // No updates - complete stillness
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
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
            
            // Single directional light with slight shimmer potential
            let light = DirectionalLight()
            light.light.intensity = 1500
            light.position = [2, 2, 2]
            anchor.addChild(light)
        }
        
        func loadModel(anchor: AnchorEntity) {
            Task { @MainActor [weak self] in
                do {
                    let model = try await ModelEntity(named: "sls.usdz")
                    self?.modelEntity = model
                    
                    // Center model perfectly
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
