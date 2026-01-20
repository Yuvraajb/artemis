//
//  Model3DView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI
import RealityKit
import Combine
import UIKit
import simd

/// 3D Viewer: Displays model with touch interactions (rotate, zoom, pan)
struct Model3DView: UIViewRepresentable {
    let vehicle: VehicleModel
    @Binding var isARMode: Bool
    @Binding var resetTrigger: Bool

    func makeUIView(context: Context) -> ModelView {
        let view = ModelView()
        view.loadModel(vehicle.modelFileName)
        context.coordinator.view = view
        return view
    }

    func updateUIView(_ uiView: ModelView, context: Context) {
        context.coordinator.view = uiView
        if resetTrigger {
            uiView.resetCamera()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator {
        var view: ModelView?
    }
}

/// Custom UIView wrapper for RealityKit 3D model viewing
class ModelView: UIView {
    private var arView: ARView?
    private var modelEntity: ModelEntity?
    private var modelAnchor: AnchorEntity?
    private var cameraEntity: PerspectiveCamera?
    private var cancellables = Set<AnyCancellable>()

    // Camera state for orbit controls
    private var cameraDistance: Float = 3.0
    private var cameraAngleX: Float = 0.0
    private var cameraAngleY: Float = 0.0
    private var lastPanLocation: CGPoint = .zero
    private var initialCameraDistance: Float = 3.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupARView()
        setupGestures()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupARView()
        setupGestures()
    }

    private func setupARView() {
        let arView = ARView(frame: bounds)
        arView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        arView.backgroundColor = .black

        // Configure for 3D viewing (not AR tracking)
        arView.environment.background = .color(.black)

        // Create anchor for the model
        let anchor = AnchorEntity()
        arView.scene.addAnchor(anchor)
        modelAnchor = anchor

        // Set up camera with orbit controls
        let camera = PerspectiveCamera()
        updateCameraPosition(camera: camera)
        anchor.addChild(camera)
        cameraEntity = camera
        arView.cameraMode = .nonAR

        // Create lighting
        let light = DirectionalLight()
        light.light.intensity = 1000
        light.position = [2, 2, 2]
        anchor.addChild(light)

        self.arView = arView
        addSubview(arView)
    }

    private func setupGestures() {
        // Pan gesture for rotation
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)

        // Pinch gesture for zoom
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinchGesture)

        // Two-finger pan for panning
        let twoFingerPan = UIPanGestureRecognizer(target: self, action: #selector(handleTwoFingerPan(_:)))
        twoFingerPan.minimumNumberOfTouches = 2
        twoFingerPan.maximumNumberOfTouches = 2
        addGestureRecognizer(twoFingerPan)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let camera = cameraEntity else { return }

        let translation = gesture.translation(in: self)
        let sensitivity: Float = 0.01

        cameraAngleY += Float(translation.x) * sensitivity
        cameraAngleX += Float(translation.y) * sensitivity
        cameraAngleX = max(-Float.pi / 2 + 0.1, min(Float.pi / 2 - 0.1, cameraAngleX))

        updateCameraPosition(camera: camera)
        gesture.setTranslation(.zero, in: self)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began {
            initialCameraDistance = cameraDistance
        }

        let scale = Float(gesture.scale)
        cameraDistance = initialCameraDistance / scale
        cameraDistance = max(1.0, min(10.0, cameraDistance))

        guard let camera = cameraEntity else { return }
        updateCameraPosition(camera: camera)
    }

    @objc private func handleTwoFingerPan(_ gesture: UIPanGestureRecognizer) {
        guard let camera = cameraEntity, let anchor = modelAnchor else { return }

        let translation = gesture.translation(in: self)
        let sensitivity: Float = 0.005

        // Calculate right and up vectors from camera orientation
        // Forward vector is from camera position to origin (where model is)
        let forward = simd_normalize(-camera.position)
        // Right vector is cross product of forward and world up
        let worldUp: simd_float3 = [0, 1, 0]
        let right = simd_normalize(simd_cross(forward, worldUp))
        // Up vector is cross product of right and forward
        let up = simd_normalize(simd_cross(right, forward))

        let panDelta = (right * Float(translation.x) - up * Float(translation.y)) * sensitivity
        anchor.position += panDelta

        gesture.setTranslation(.zero, in: self)
    }

    private func updateCameraPosition(camera: PerspectiveCamera) {
        let x = cameraDistance * cos(cameraAngleX) * sin(cameraAngleY)
        let y = cameraDistance * sin(cameraAngleX)
        let z = cameraDistance * cos(cameraAngleX) * cos(cameraAngleY)

        camera.position = [x, y, z]
        camera.look(at: [0, 0, 0], from: camera.position, relativeTo: nil)
    }

    func resetCamera() {
        guard let camera = cameraEntity, let anchor = modelAnchor else { return }
        cameraDistance = 3.0
        cameraAngleX = 0.0
        cameraAngleY = 0.0
        anchor.position = [0, 0, 0]
        updateCameraPosition(camera: camera)
    }

    func loadModel(_ fileName: String) {
        guard let arView = arView, let anchor = modelAnchor else { return }

        // Remove existing model if any
        if let existingModel = modelEntity {
            existingModel.removeFromParent()
        }

        // Attempt to load model using new iOS 18+ API
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                let model = try await ModelEntity(named: fileName)
                self.modelEntity = model
                anchor.addChild(model)
                self.centerModel(model, in: arView)
            } catch {
                print("Failed to load model: \(error)")
                // Create a placeholder shape
                self.createPlaceholderModel(anchor: anchor)
            }
        }
    }

    private func createPlaceholderModel(anchor: AnchorEntity) {
        // Create a simple geometric shape as placeholder
        let mesh = MeshResource.generateBox(size: 1.0)
        let material = SimpleMaterial(color: .systemBlue, roughness: 0.5, isMetallic: true)
        let placeholder = ModelEntity(mesh: mesh, materials: [material])
        placeholder.position = [0, 0, -2]
        anchor.addChild(placeholder)
        self.modelEntity = placeholder
    }

    private func centerModel(_ model: ModelEntity, in arView: ARView) {
        // Center the model in view
        let bounds = model.visualBounds(relativeTo: nil)
        let center = bounds.center
        model.position = [0, 0, -2] - center
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        arView?.frame = bounds
    }
}

