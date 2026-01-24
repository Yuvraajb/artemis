//
//  ArrivalView.swift
//  artemis
//
//  Step 1: Emotional hook - sets tone and gravity
//

import SwiftUI
import RealityKit

struct ArrivalView: View {
    let onContinue: () -> Void
    let reduceMotion: Bool
    
    @State private var showStars = false
    @State private var showEarth = false
    @State private var showFirstText = false
    @State private var showSecondText = false
    @State private var earthRotation: Float = 0
    
    var body: some View {
        ZStack {
            // Black background
            Color.black.ignoresSafeArea()
            
            // Earth visualization with stars
            EarthView(
                rotation: earthRotation,
                showStars: showStars,
                showEarth: showEarth
            )
            
            // Text overlay (Center, Large)
            VStack(spacing: 20) {
                if showFirstText {
                    Text("We're going back to the Moon.")
                        .font(.system(size: 32, weight: .light, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                        .accessibilityLabel("We're going back to the Moon.")
                }
                
                if showSecondText {
                    Text("And beyond.")
                        .font(.system(size: 28, weight: .light, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                        .accessibilityLabel("And beyond.")
                }
            }
            .padding(.horizontal, 40)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onContinue()
        }
        .onAppear {
            // Sequence: Stars fade in → Earth fades in → Text appears
            if !reduceMotion {
                // Stars fade in slowly
                withAnimation(.easeIn(duration: 2.0)) {
                    showStars = true
                }
                
                // Earth fades in after stars
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.easeIn(duration: 1.5)) {
                        showEarth = true
                    }
                }
                
                // Earth rotates very slowly (barely perceptible)
                withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                    earthRotation = .pi * 2
                }
                
                // First text after Earth appears (~0.6s fade-in)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                    withAnimation(.easeIn(duration: 0.6)) {
                        showFirstText = true
                    }
                }
                
                // Second text after ~2 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    withAnimation(.easeIn(duration: 0.6)) {
                        showSecondText = true
                    }
                }
            } else {
                // Reduced motion: show everything immediately
                showStars = true
                showEarth = true
                showFirstText = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    showSecondText = true
                }
            }
        }
    }
}

/// Simple Earth visualization using RealityKit
struct EarthView: UIViewRepresentable {
    let rotation: Float
    let showStars: Bool
    let showEarth: Bool
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.backgroundColor = .black
        
        // Configure for 3D viewing (not AR tracking)
        arView.environment.background = .color(.black)
        arView.cameraMode = .nonAR
        
        // Create anchor
        let anchor = AnchorEntity()
        arView.scene.addAnchor(anchor)
        
        // Create tiny stars (low density)
        for _ in 0..<30 {
            let star = PointLight()
            star.light.intensity = Float.random(in: 20...80)
            star.position = [
                Float.random(in: -10...10),
                Float.random(in: -10...10),
                Float.random(in: (-8)...(-4))
            ]
            star.isEnabled = showStars
            anchor.addChild(star)
            context.coordinator.stars.append(star)
        }
        
        // Create Earth sphere
        let earthMesh = MeshResource.generateSphere(radius: 1.0)
        let earthMaterial = SimpleMaterial(
            color: UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
            roughness: 0.8,
            isMetallic: false
        )
        let earth = ModelEntity(mesh: earthMesh, materials: [earthMaterial])
        earth.position = [0, 0, -3]
        earth.isEnabled = showEarth
        anchor.addChild(earth)
        
        // Set up camera (fixed, no parallax, no zoom)
        let camera = PerspectiveCamera()
        camera.position = [0, 0, 0]
        camera.look(at: [0, 0, -3], from: camera.position, relativeTo: nil)
        anchor.addChild(camera)
        
        // Store references
        context.coordinator.earthEntity = earth
        context.coordinator.anchor = anchor
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // Update Earth rotation (very slowly)
        if let earth = context.coordinator.earthEntity {
            earth.orientation = simd_quatf(angle: rotation, axis: [0, 1, 0])
            earth.isEnabled = showEarth
        }
        
        // Update stars visibility
        for star in context.coordinator.stars {
            star.isEnabled = showStars
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var earthEntity: ModelEntity?
        var anchor: AnchorEntity?
        var stars: [PointLight] = []
    }
}
