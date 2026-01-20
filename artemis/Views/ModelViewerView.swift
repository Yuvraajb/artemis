//
//  ModelViewerView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI
import RealityKit

/// Model Viewer Screen: Displays 3D model with option to switch to AR mode
struct ModelViewerView: View {
    let vehicle: VehicleModel
    @State private var isARMode = false
    @State private var showARView = false
    @State private var resetTrigger = false

    var body: some View {
        ZStack {
            if showARView {
                ARViewContainer(vehicle: vehicle, isARMode: $isARMode)
            } else {
                Model3DView(vehicle: vehicle, isARMode: $isARMode, resetTrigger: $resetTrigger)
            }

            // Top controls overlay
            VStack {
                HStack {
                    if !showARView {
                        Button(action: {
                            resetTrigger.toggle()
                        }) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Reset camera view")
                        .accessibilityHint("Resets the model to its original position and zoom")
                    }

                    Spacer()

                    Button(action: {
                        isARMode.toggle()
                        if isARMode {
                            showARView = true
                        } else {
                            showARView = false
                        }
                    }) {
                        HStack {
                            Image(systemName: isARMode ? "cube" : "arkit")
                            Text(isARMode ? "3D View" : "View in AR")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .accessibilityLabel(isARMode ? "Switch to 3D view" : "Switch to AR view")
                }
                .padding()

                Spacer()
            }
        }
        .navigationTitle(vehicle.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }
}

#Preview {
    NavigationStack {
        ModelViewerView(vehicle: .sls)
    }
}

