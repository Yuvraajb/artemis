//
//  ARGameARView.swift
//  artemis
//
//  AR view implementation for Rocket Launch Game
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct ARGameARView: UIViewRepresentable {
    @ObservedObject var gameState: ARGameState
    let onComplete: () -> Void
    
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
        
        context.coordinator.setupARView(arView, gameState: gameState, onComplete: onComplete)
        return arView
    }
    
        func updateUIView(_ uiView: ARView, context: Context) {
            // Update button visual states based on game state
            context.coordinator.updateButtonStates(gameState: gameState)
            
            // Update placement guide visibility
            if gameState.phase == .placing && gameState.moonEntity != nil {
                // Ensure guide is visible
                if gameState.placementGuideEntity == nil {
                    // Recreate guide if needed
                    if let moon = gameState.moonEntity, let anchor = context.coordinator.anchorEntity {
                        context.coordinator.createPlacementGuideIfNeeded(gameState: gameState, moon: moon, anchor: anchor)
                    }
                }
            } else {
                // Remove guides when not in placing phase
                if let guide = gameState.placementGuideEntity {
                    guide.removeFromParent()
                    gameState.placementGuideEntity = nil
                }
                if let target = gameState.placementTargetEntity {
                    target.removeFromParent()
                    gameState.placementTargetEntity = nil
                }
            }
        }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
        class Coordinator: NSObject {
            var arView: ARView?
            var gameState: ARGameState?
            var onComplete: (() -> Void)?
            var anchorEntity: AnchorEntity?
            var cancellables = Set<AnyCancellable>()
            
            func createPlacementGuideIfNeeded(gameState: ARGameState, moon: ModelEntity, anchor: AnchorEntity) {
                if gameState.placementGuideEntity == nil {
                    self.createPlacementGuide(gameState: gameState, moon: moon, anchor: anchor)
                }
            }
        
        func setupARView(_ arView: ARView, gameState: ARGameState, onComplete: @escaping () -> Void) {
            self.arView = arView
            self.gameState = gameState
            self.onComplete = onComplete
            
            // Create anchor entity for the scene
            let anchor = AnchorEntity(.world(transform: matrix_identity_float4x4))
            arView.scene.addAnchor(anchor)
            self.anchorEntity = anchor
            
            // Wait a moment for AR session to initialize, then spawn moon
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.spawnMoonInSpace(gameState: gameState, anchor: anchor, arView: arView)
            }
            
            // Add tap gesture
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
            arView.addGestureRecognizer(tapGesture)
        }
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let arView = arView, let gameState = gameState, let anchor = anchorEntity else { return }
            
            let location = gesture.location(in: arView)
            
            switch gameState.phase {
            case .findingMoon:
                // Check if user tapped the moon
                if let hitEntity = arView.entity(at: location) as? ModelEntity {
                    if hitEntity.name == "MOON" {
                        handleMoonTap(gameState: gameState)
                    }
                } else {
                    // Fallback: check if tap is near moon position
                    let results = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .any)
                    if let result = results.first {
                        let hitPosition = SIMD3<Float>(
                            result.worldTransform.columns.3.x,
                            result.worldTransform.columns.3.y,
                            result.worldTransform.columns.3.z
                        )
                        
                        if let moon = gameState.moonEntity {
                            let moonWorldTransform = moon.transformMatrix(relativeTo: nil)
                            let moonPosition = SIMD3<Float>(
                                moonWorldTransform.columns.3.x,
                                moonWorldTransform.columns.3.y,
                                moonWorldTransform.columns.3.z
                            )
                            
                            let distanceToMoon = distance(hitPosition, moonPosition)
                            if distanceToMoon < 1.0 { // Within 1 meter
                                handleMoonTap(gameState: gameState)
                            }
                        }
                    }
                }
                
            case .placing:
                // Place launch pad on horizontal plane, preferably below moon
                let results = arView.raycast(
                    from: location,
                    allowing: .estimatedPlane,
                    alignment: .horizontal
                )
                
                if let result = results.first {
                    // Validate placement is below moon
                    let hitPosition = SIMD3<Float>(
                        result.worldTransform.columns.3.x,
                        result.worldTransform.columns.3.y,
                        result.worldTransform.columns.3.z
                    )
                    
                    if let moon = gameState.moonEntity {
                        let moonWorldTransform = moon.transformMatrix(relativeTo: nil)
                        let moonPosition = SIMD3<Float>(
                            moonWorldTransform.columns.3.x,
                            moonWorldTransform.columns.3.y,
                            moonWorldTransform.columns.3.z
                        )
                        
                        // Check if placement is below moon (within reasonable horizontal distance)
                        let horizontalDistance = sqrt(
                            pow(hitPosition.x - moonPosition.x, 2) +
                            pow(hitPosition.z - moonPosition.z, 2)
                        )
                        
                        // Allow placement if within 1.5 meters horizontally from moon's position
                        if horizontalDistance < 1.5 && hitPosition.y < moonPosition.y {
                            placeLaunchPad(at: result, anchor: anchor, gameState: gameState)
                            
                            // Remove placement guides
                            if let guide = gameState.placementGuideEntity {
                                guide.removeFromParent()
                                gameState.placementGuideEntity = nil
                            }
                            if let target = gameState.placementTargetEntity {
                                target.removeFromParent()
                                gameState.placementTargetEntity = nil
                            }
                        }
                    } else {
                        // Fallback: allow placement even if moon check fails
                        placeLaunchPad(at: result, anchor: anchor, gameState: gameState)
                    }
                }
                
            case .systemsCheck, .fueling, .ready:
                // Try entity hit test first (most reliable for 3D objects)
                if let hitEntity = arView.entity(at: location) as? ModelEntity {
                    let buttonName = hitEntity.name
                    if !buttonName.isEmpty && (buttonName == "SYSTEMS" || buttonName == "FUEL" || buttonName == "LAUNCH") {
                        handleButtonTap(entity: hitEntity, gameState: gameState)
                    }
                } else {
                    // Fallback: Check if tap is near button positions
                    let results = arView.raycast(from: location, allowing: .existingPlaneGeometry, alignment: .any)
                    if let result = results.first {
                        let hitPosition = SIMD3<Float>(
                            result.worldTransform.columns.3.x,
                            result.worldTransform.columns.3.y,
                            result.worldTransform.columns.3.z
                        )
                        
                        // Check which button is closest
                        if let systemsButton = gameState.systemsCheckButton,
                           let fuelButton = gameState.fuelButton,
                           let launchButton = gameState.launchButton {
                            
                            let systemsPos = systemsButton.position
                            let fuelPos = fuelButton.position
                            let launchPos = launchButton.position
                            
                            let buttonSize: Float = 0.15 // Larger hit area
                            
                            let distSystems = distance(hitPosition, systemsPos)
                            let distFuel = distance(hitPosition, fuelPos)
                            let distLaunch = distance(hitPosition, launchPos)
                            
                            if distSystems < buttonSize && distSystems <= distFuel && distSystems <= distLaunch {
                                handleButtonTap(entity: systemsButton, gameState: gameState)
                            } else if distFuel < buttonSize && distFuel <= distLaunch {
                                handleButtonTap(entity: fuelButton, gameState: gameState)
                            } else if distLaunch < buttonSize {
                                handleButtonTap(entity: launchButton, gameState: gameState)
                            }
                        }
                    }
                }
                
            default:
                break
            }
        }
        
        private func placeLaunchPad(at raycastResult: ARRaycastResult, anchor: AnchorEntity, gameState: ARGameState) {
            let position = SIMD3<Float>(
                raycastResult.worldTransform.columns.3.x,
                raycastResult.worldTransform.columns.3.y,
                raycastResult.worldTransform.columns.3.z
            )
            
            // Create launch pad base
            let padMesh = MeshResource.generateBox(size: [0.5, 0.05, 0.5])
            let padMaterial = SimpleMaterial(color: .gray, roughness: 0.5, isMetallic: false)
            let launchPad = ModelEntity(mesh: padMesh, materials: [padMaterial])
            launchPad.position = position
            anchor.addChild(launchPad)
            gameState.launchPadEntity = launchPad
            
            // Create rocket (cylinder body + cone nose)
            let bodyMesh = MeshResource.generateCylinder(height: 0.4, radius: 0.06)
            let noseMesh = MeshResource.generateCone(height: 0.12, radius: 0.06)
            let rocketMaterial = SimpleMaterial(color: .white, roughness: 0.3, isMetallic: true)
            
            let rocketBody = ModelEntity(mesh: bodyMesh, materials: [rocketMaterial])
            rocketBody.position = [0, 0.2, 0]
            
            let rocketNose = ModelEntity(mesh: noseMesh, materials: [rocketMaterial])
            rocketNose.position = [0, 0.42, 0]
            
            let rocket = ModelEntity()
            rocket.addChild(rocketBody)
            rocket.addChild(rocketNose)
            rocket.position = position + SIMD3<Float>(0, 0.2, 0)
            rocket.generateCollisionShapes(recursive: true)
            
            anchor.addChild(rocket)
            gameState.rocketEntity = rocket
            gameState.isRocketPlaced = true
            
            // Create 3D buttons on launch pad
            createLaunchPadButtons(anchor: anchor, launchPadPosition: position, gameState: gameState)
            
            gameState.phase = .systemsCheck
        }
        
        private func handleMoonTap(gameState: ARGameState) {
            // Moon found! Allow placing launch pad
            gameState.moonFound = true
            gameState.phase = .placing
            
            // Visual feedback - make moon glow
            if let moon = gameState.moonEntity, let anchor = anchorEntity {
                moon.model?.materials = [SimpleMaterial(
                    color: UIColor(white: 0.9, alpha: 1.0),
                    roughness: 0.3,
                    isMetallic: true
                )]
                
                // Create visual guide from moon to ground
                createPlacementGuide(gameState: gameState, moon: moon, anchor: anchor)
            }
        }
        
        private func createPlacementGuide(gameState: ARGameState, moon: ModelEntity, anchor: AnchorEntity) {
            let moonPosition = moon.position
            
            // Place target 1.5 meters directly below the moon (closer for easier placement)
            let targetY = moonPosition.y - 1.5
            let targetPosition = SIMD3<Float>(moonPosition.x, targetY, moonPosition.z)
            
            // Create a vertical line from moon pointing down to target
            let guideLineLength: Float = 1.5
            let lineMesh = MeshResource.generateCylinder(height: guideLineLength, radius: 0.015)
            let lineMaterial = SimpleMaterial(
                color: UIColor.systemBlue.withAlphaComponent(0.7),
                roughness: 0.5,
                isMetallic: false
            )
            let guideLine = ModelEntity(mesh: lineMesh, materials: [lineMaterial])
            guideLine.position = SIMD3<Float>(moonPosition.x, moonPosition.y - guideLineLength / 2, moonPosition.z)
            guideLine.orientation = simd_quatf(angle: Float.pi / 2, axis: [1, 0, 0]) // Rotate to vertical
            anchor.addChild(guideLine)
            gameState.placementGuideEntity = guideLine
            
            // Create a placement target circle on the ground
            let targetMesh = MeshResource.generateCylinder(height: 0.02, radius: 0.35)
            let targetMaterial = SimpleMaterial(
                color: UIColor.systemGreen.withAlphaComponent(0.6),
                roughness: 0.3,
                isMetallic: false
            )
            let target = ModelEntity(mesh: targetMesh, materials: [targetMaterial])
            target.position = targetPosition
            anchor.addChild(target)
            gameState.placementTargetEntity = target
            
            // Add pulsing animation to target
            let originalScale: Float = 1.0
            let pulseScale: Float = 1.3
            
            func pulse() {
                let scaleUp = Transform(
                    scale: [pulseScale, 1, pulseScale],
                    rotation: target.orientation,
                    translation: target.position
                )
                let scaleDown = Transform(
                    scale: [originalScale, 1, originalScale],
                    rotation: target.orientation,
                    translation: target.position
                )
                
                target.move(to: scaleUp, relativeTo: anchor, duration: 1.0, timingFunction: .easeInOut)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    target.move(to: scaleDown, relativeTo: anchor, duration: 1.0, timingFunction: .easeInOut)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        if gameState.phase == .placing {
                            pulse()
                        }
                    }
                }
            }
            pulse()
        }
        
        private func createLaunchPadButtons(anchor: AnchorEntity, launchPadPosition: SIMD3<Float>, gameState: ARGameState) {
            // Systems Check Button (left)
            let systemsButton = createButton(
                position: launchPadPosition + SIMD3<Float>(-0.15, 0.03, 0),
                color: .blue,
                label: "SYSTEMS"
            )
            anchor.addChild(systemsButton)
            gameState.systemsCheckButton = systemsButton
            
            // Fuel Button (center)
            let fuelButton = createButton(
                position: launchPadPosition + SIMD3<Float>(0, 0.03, 0),
                color: .orange,
                label: "FUEL"
            )
            anchor.addChild(fuelButton)
            gameState.fuelButton = fuelButton
            
            // Launch Button (right)
            let launchButton = createButton(
                position: launchPadPosition + SIMD3<Float>(0.15, 0.03, 0),
                color: .red,
                label: "LAUNCH"
            )
            anchor.addChild(launchButton)
            gameState.launchButton = launchButton
        }
        
        private func createButton(position: SIMD3<Float>, color: UIColor, label: String) -> ModelEntity {
            // Button base - make it bigger and taller for easier tapping
            let buttonMesh = MeshResource.generateBox(size: [0.12, 0.03, 0.12])
            let buttonMaterial = SimpleMaterial(color: color, roughness: 0.3, isMetallic: false)
            let button = ModelEntity(mesh: buttonMesh, materials: [buttonMaterial])
            button.position = position
            button.generateCollisionShapes(recursive: true)
            
            // Store label in component for identification
            button.name = label
            
            return button
        }
        
        private func handleButtonTap(entity: ModelEntity, gameState: ARGameState) {
            let buttonName = entity.name
            
            guard !buttonName.isEmpty else { return }
            
            switch buttonName {
            case "SYSTEMS":
                handleSystemsCheck(gameState: gameState)
            case "FUEL":
                handleFuel(gameState: gameState)
            case "LAUNCH":
                handleLaunch(gameState: gameState)
            default:
                break
            }
        }
        
        private func handleSystemsCheck(gameState: ARGameState) {
            guard gameState.phase == .systemsCheck || gameState.phase == .ready else { return }
            guard !gameState.systemsChecked else { return }
            
            // Check next system
            gameState.checkNextSystem()
            
            // Visual feedback - button press animation
            if let button = gameState.systemsCheckButton {
                let originalPosition = button.position
                button.position = originalPosition + SIMD3<Float>(0, -0.005, 0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    button.position = originalPosition
                }
            }
            
            // If all systems checked, move to fueling phase
            if gameState.systemsChecked {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if !gameState.fuelComplete {
                        gameState.phase = .fueling
                    } else {
                        gameState.phase = .ready
                    }
                }
            }
        }
        
        private func handleFuel(gameState: ARGameState) {
            guard gameState.phase == .fueling || gameState.phase == .ready else { return }
            guard !gameState.fuelComplete else { return }
            
            // Add fuel
            gameState.addFuel(amount: 15.0)
            
            // Visual feedback - button press animation
            if let button = gameState.fuelButton {
                let originalPosition = button.position
                button.position = originalPosition + SIMD3<Float>(0, -0.005, 0)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    button.position = originalPosition
                }
            }
            
            // If fuel complete, move to ready phase
            if gameState.fuelComplete {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if gameState.systemsChecked {
                        gameState.phase = .ready
                    } else {
                        gameState.phase = .systemsCheck
                    }
                }
            }
        }
        
        private func handleLaunch(gameState: ARGameState) {
            guard gameState.canLaunch else { return }
            guard let rocket = gameState.rocketEntity, let anchor = anchorEntity else { return }
            
            gameState.isLaunching = true
            gameState.phase = .launching
            
            // Countdown
            gameState.countdown = 3
            startCountdown(gameState: gameState, rocket: rocket, anchor: anchor)
        }
        
        private func startCountdown(gameState: ARGameState, rocket: ModelEntity, anchor: AnchorEntity) {
            if gameState.countdown <= 0 {
                // Launch!
                launchRocket(gameState: gameState, rocket: rocket, anchor: anchor)
                return
            }
            
            // Visual countdown feedback on launch button
            if let button = gameState.launchButton {
                let countdownColor = UIColor(white: 1.0, alpha: 0.5)
                button.model?.materials = [SimpleMaterial(color: countdownColor, roughness: 0.3, isMetallic: false)]
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    button.model?.materials = [SimpleMaterial(color: .green, roughness: 0.3, isMetallic: false)]
                    gameState.countdown -= 1
                    self.startCountdown(gameState: gameState, rocket: rocket, anchor: anchor)
                }
            }
        }
        
        private func distance(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float {
            let dx = a.x - b.x
            let dy = a.y - b.y
            let dz = a.z - b.z
            return sqrt(dx * dx + dy * dy + dz * dz)
        }
        
        private func spawnMoonInSpace(gameState: ARGameState, anchor: AnchorEntity, arView: ARView) {
            // Get camera position to place moon relative to user's initial view
            guard let frame = arView.session.currentFrame else {
            // Fallback: use fixed position (closer to user)
            let moonPosition = SIMD3<Float>(0, 1.5, -0.8)
            createMoonAtPosition(gameState: gameState, anchor: anchor, position: moonPosition, arView: arView)
                return
            }
            
            let cameraTransform = frame.camera.transform
            let cameraPosition = SIMD3<Float>(
                cameraTransform.columns.3.x,
                cameraTransform.columns.3.y,
                cameraTransform.columns.3.z
            )
            
            // Position moon above and in front of camera (user's head)
            // Convert to anchor's coordinate space
            let anchorTransform = anchor.transformMatrix(relativeTo: nil)
            let anchorPosition = SIMD3<Float>(
                anchorTransform.columns.3.x,
                anchorTransform.columns.3.y,
                anchorTransform.columns.3.z
            )
            
            // Calculate moon position relative to anchor
            // Place it above and close in front of user (within arm's reach)
            let offsetFromCamera = SIMD3<Float>(0, 1.5, -0.8) // Closer: 1.5m up, 0.8m in front
            let moonWorldPosition = cameraPosition + offsetFromCamera
            let moonPosition = moonWorldPosition - anchorPosition
            
            createMoonAtPosition(gameState: gameState, anchor: anchor, position: moonPosition, arView: arView)
        }
        
        private func createMoonAtPosition(gameState: ARGameState, anchor: AnchorEntity, position: SIMD3<Float>, arView: ARView) {
            // Create moon (large gray sphere)
            let moonMesh = MeshResource.generateSphere(radius: 0.3)
            let moonMaterial = SimpleMaterial(
                color: UIColor(white: 0.7, alpha: 1.0),
                roughness: 0.8,
                isMetallic: false
            )
            let moon = ModelEntity(mesh: moonMesh, materials: [moonMaterial])
            moon.position = position
            moon.name = "MOON"
            moon.generateCollisionShapes(recursive: true)
            
            // Add subtle rotation animation
            let rotation = simd_quatf(angle: Float.pi * 2, axis: [0, 1, 0])
            moon.move(
                to: Transform(
                    scale: moon.scale,
                    rotation: rotation,
                    translation: position
                ),
                relativeTo: anchor,
                duration: 20.0,
                timingFunction: .linear
            )
            
            anchor.addChild(moon)
            gameState.moonEntity = moon
            
            // Start tracking moon direction for arrow indicators
            startMoonDirectionTracking(gameState: gameState, moon: moon, arView: arView)
        }
        
        private func launchRocket(gameState: ARGameState, rocket: ModelEntity, anchor: AnchorEntity) {
            guard let moon = gameState.moonEntity else {
                gameState.phase = .completed
                return
            }
            
            gameState.isRocketLaunched = true
            gameState.phase = .launched
            
            // Get moon position (relative to anchor)
            let moonPosition = moon.position
            
            // Get rocket starting position (relative to anchor)
            let rocketStartPosition = rocket.position
            
            // Calculate direction to moon (in anchor's coordinate space)
            let directionToMoon = moonPosition - rocketStartPosition
            let distanceToMoon = length(directionToMoon)
            
            // Launch rocket toward moon (target is moon's position)
            let targetPosition = moonPosition
            
            // Launch animation - rocket moves toward moon
            rocket.move(
                to: Transform(
                    scale: rocket.scale,
                    rotation: rocket.orientation,
                    translation: targetPosition
                ),
                relativeTo: anchor,
                duration: 3.0,
                timingFunction: .easeOut
            )
            
            // Check if rocket touches moon after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                // Get final rocket position (relative to anchor)
                let finalRocketPosition = rocket.position
                
                // Check if rocket is close enough to moon (touching)
                // Moon radius is 0.3, so we need to be within that + some margin
                let finalDistance = self.distance(finalRocketPosition, moonPosition)
                let touchThreshold: Float = 0.4 // 0.4 meters = touching (moon radius 0.3 + margin)
                
                if finalDistance <= touchThreshold {
                    // Mission passed - rocket touched moon!
                    gameState.phase = .completed
                    // Mark AR game as completed
                    UserDefaults.standard.set(true, forKey: "arGameCompleted")
                } else {
                    // Mission failed - rocket didn't reach moon
                    gameState.phase = .completed
                }
            }
        }
        
        private func startMoonDirectionTracking(gameState: ARGameState, moon: ModelEntity, arView: ARView) {
            // Update moon direction continuously for arrow indicators
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
                guard let self = self,
                      let arView = self.arView,
                      gameState.phase == .findingMoon else {
                    timer.invalidate()
                    return
                }
                
                self.updateMoonDirection(gameState: gameState, moon: moon, arView: arView)
            }
        }
        
        private func updateMoonDirection(gameState: ARGameState, moon: ModelEntity, arView: ARView) {
            guard let frame = arView.session.currentFrame else { return }
            
            let cameraTransform = frame.camera.transform
            let cameraPosition = SIMD3<Float>(
                cameraTransform.columns.3.x,
                cameraTransform.columns.3.y,
                cameraTransform.columns.3.z
            )
            
            // Get moon position in world space
            let moonWorldTransform = moon.transformMatrix(relativeTo: nil)
            let moonPosition = SIMD3<Float>(
                moonWorldTransform.columns.3.x,
                moonWorldTransform.columns.3.y,
                moonWorldTransform.columns.3.z
            )
            
            // Calculate direction to moon from camera
            let directionToMoon = moonPosition - cameraPosition
            let distanceToMoon = length(directionToMoon)
            
            // Get camera orientation vectors
            let cameraForward = SIMD3<Float>(
                -cameraTransform.columns.2.x,
                -cameraTransform.columns.2.y,
                -cameraTransform.columns.2.z
            )
            let cameraRight = SIMD3<Float>(
                cameraTransform.columns.0.x,
                cameraTransform.columns.0.y,
                cameraTransform.columns.0.z
            )
            let cameraUp = SIMD3<Float>(
                cameraTransform.columns.1.x,
                cameraTransform.columns.1.y,
                cameraTransform.columns.1.z
            )
            
            // Normalize direction
            let normalizedDirection = normalize(directionToMoon)
            
            // Project direction onto camera's right and up vectors for 2D screen space
            let rightComponent = dot(normalizedDirection, normalize(cameraRight))
            let upComponent = dot(normalizedDirection, normalize(cameraUp))
            
            // Store direction for arrow indicators
            gameState.moonDirection = SIMD3<Float>(rightComponent, upComponent, 0)
            gameState.moonDistance = distanceToMoon
        }
        
        private func length(_ vector: SIMD3<Float>) -> Float {
            return sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
        }
        
        private func normalize(_ vector: SIMD3<Float>) -> SIMD3<Float> {
            let len = length(vector)
            guard len > 0 else { return SIMD3<Float>(0, 0, 0) }
            return vector / len
        }
        
        private func dot(_ a: SIMD3<Float>, _ b: SIMD3<Float>) -> Float {
            return a.x * b.x + a.y * b.y + a.z * b.z
        }
        
        func updateButtonStates(gameState: ARGameState) {
            // Update button colors based on state
            if let systemsButton = gameState.systemsCheckButton {
                let color: UIColor = gameState.systemsChecked ? .green : .blue
                systemsButton.model?.materials = [SimpleMaterial(color: color, roughness: 0.3, isMetallic: false)]
            }
            
            if let fuelButton = gameState.fuelButton {
                let color: UIColor = gameState.fuelComplete ? .green : .orange
                fuelButton.model?.materials = [SimpleMaterial(color: color, roughness: 0.3, isMetallic: false)]
            }
            
            if let launchButton = gameState.launchButton {
                let color: UIColor = gameState.canLaunch ? .green : .red
                launchButton.model?.materials = [SimpleMaterial(color: color, roughness: 0.3, isMetallic: false)]
            }
        }
    }
}
