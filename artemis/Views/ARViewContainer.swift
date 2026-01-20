//
//  ARViewContainer.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

/// AR View Container: Handles AR placement and interaction
struct ARViewContainer: UIViewRepresentable {
    let vehicle: VehicleModel
    @Binding var isARMode: Bool

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal]
        config.environmentTexturing = .automatic
        arView.session.run(config)

        // Add coaching overlay for plane detection
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

        context.coordinator.setupARView(arView, vehicle: vehicle)
        return arView
    }

    func updateUIView(_ uiView: ARView, context: Context) {
        // Update if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject {
        var modelEntity: ModelEntity?
        var anchorEntity: AnchorEntity?
        var cancellables = Set<AnyCancellable>()

        func setupARView(_ arView: ARView, vehicle: VehicleModel) {
            // Tap gesture for placement
            arView.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            )

            // Load model using new iOS 18+ API
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                do {
                    let model = try await ModelEntity(named: vehicle.modelFileName)
                    self.modelEntity = model
                } catch {
                    print("Failed to load AR model: \(error)")
                    self.createPlaceholderModel()
                }
            }
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = gesture.view as? ARView,
                  let modelEntity = modelEntity else { return }

            let location = gesture.location(in: arView)

            // Raycast to find horizontal plane
            let results = arView.raycast(
                from: location,
                allowing: .estimatedPlane,
                alignment: .horizontal
            )

            if let result = results.first {
                // Place or move model
                if let existingAnchor = anchorEntity {
                    existingAnchor.removeFromParent()
                }

                // Clone the model for placement
                let modelClone = modelEntity.clone(recursive: true)
                let anchor = AnchorEntity(raycastResult: result)
                anchor.addChild(modelClone)
                arView.scene.addAnchor(anchor)
                anchorEntity = anchor

                // Enable drag, scale, and rotate gestures on the placed model
                modelClone.generateCollisionShapes(recursive: true)
                arView.installGestures([.rotation, .scale, .translation], for: modelClone)
            }
        }

        private func createPlaceholderModel() {
            let mesh = MeshResource.generateBox(size: 0.5)
            let material = SimpleMaterial(color: .systemBlue, roughness: 0.5, isMetallic: true)
            modelEntity = ModelEntity(mesh: mesh, materials: [material])
        }
    }
}

