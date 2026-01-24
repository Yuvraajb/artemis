//
//  ARPlacementView.swift
//  artemis
//
//  Step 3: Physical Understanding - turn AR into comprehension
//

import SwiftUI
import RealityKit
import ARKit

struct ARPlacementView: View {
    let onContinue: () -> Void
    
    @State private var isPlaced = false
    @State private var showWalkBackMessage = false
    @State private var showPlacementHint = true
    
    var body: some View {
        ZStack {
            OnboardingARView(
                isPlaced: $isPlaced,
                onPlacement: {
                    showWalkBackMessage = true
                    showPlacementHint = false
                }
            )
            
            // Overlay Text (Center) - Frame 04
            if !isPlaced && showPlacementHint {
                VStack {
                    Spacer()
                    Text("Place Artemis in your space.")
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .transition(.opacity)
                        .accessibilityLabel("Place Artemis in your space.")
                    Spacer()
                }
            }
            
            // Overlay Text and Next Button - Frame 05
            if isPlaced && showWalkBackMessage {
                VStack {
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("Pinch to zoom. Explore the rocket.")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(12)
                            .transition(.opacity)
                            .accessibilityLabel("Pinch to zoom. Explore the rocket.")
                        
                        // Next button - user controls when to continue
                        Button(action: {
                            onContinue()
                        }) {
                            Text("Next")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 50)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                                )
                        }
                        .transition(.opacity)
                        .accessibilityLabel("Next")
                    }
                    
                    Spacer().frame(height: 100)
                }
                .padding()
            }
        }
    }
}

/// Simplified AR view for onboarding - placement only, locked rotation
struct OnboardingARView: UIViewRepresentable {
    @Binding var isPlaced: Bool
    let onPlacement: () -> Void
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config)
        
        // Add coaching overlay
        let coachingOverlay = ARCoachingOverlayView()
        coachingOverlay.session = arView.session
        coachingOverlay.goal = .horizontalPlane
        coachingOverlay.activatesAutomatically = true
        arView.addSubview(coachingOverlay)
        coachingOverlay.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coachingOverlay.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            coachingOverlay.centerYAnchor.constraint(equalTo: arView.centerYAnchor),
            coachingOverlay.widthAnchor.constraint(equalTo: arView.widthAnchor),
            coachingOverlay.heightAnchor.constraint(equalTo: arView.heightAnchor)
        ])
        
        context.coordinator.setupARView(arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update if needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isPlaced: $isPlaced, onPlacement: onPlacement)
    }
    
    class Coordinator: NSObject {
        @Binding var isPlaced: Bool
        let onPlacement: () -> Void
        
        var modelEntity: ModelEntity?
        var anchorEntity: AnchorEntity?
        var hasPlaced = false
        var arView: ARView?
        
        init(isPlaced: Binding<Bool>, onPlacement: @escaping () -> Void) {
            _isPlaced = isPlaced
            self.onPlacement = onPlacement
        }
        
        func setupARView(_ arView: ARView) {
            self.arView = arView
            
            // Tap gesture for placement
            arView.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            )
            
            // Load model
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                do {
                    let model = try await ModelEntity(named: "sls.usdz")
                    self.modelEntity = model
                } catch {
                    print("Failed to load AR model: \(error)")
                    self.createPlaceholderModel()
                }
            }
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = gesture.view as? ARView,
                  let modelEntity = modelEntity,
                  !hasPlaced else { return }
            
            let location = gesture.location(in: arView)
            
            // Raycast to find horizontal plane
            let results = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )
            
            if let result = results.first {
                hasPlaced = true
                
                // Remove existing anchor if any
                if let existingAnchor = anchorEntity {
                    existingAnchor.removeFromParent()
                }
                
                // Place model
                let modelClone = modelEntity.clone(recursive: true)
                let anchor = AnchorEntity(raycastResult: result)
                anchor.addChild(modelClone)
                arView.scene.addAnchor(anchor)
                anchorEntity = anchor
                
                // Enable pinch/zoom and scale gestures
                modelClone.generateCollisionShapes(recursive: true)
                arView.installGestures([.scale], for: modelClone)
                
                // Update state
                isPlaced = true
                onPlacement()
            }
        }
        
        
        private func createPlaceholderModel() {
            let mesh = MeshResource.generateBox(size: [0.3, 2.0, 0.3])
            let material = SimpleMaterial(color: .white, roughness: 0.3, isMetallic: true)
            modelEntity = ModelEntity(mesh: mesh, materials: [material])
        }
    }
}
