//
//  ModelSelectionView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

/// Model Selection Screen: Choose between SLS and Orion
struct ModelSelectionView: View {
    @State private var selectedVehicle: VehicleModel?
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("3D Models")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Explore NASA's Artemis vehicles")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Vehicle Cards
                        VStack(spacing: 16) {
                            VehicleCard(
                                vehicle: .sls,
                                title: "Space Launch System",
                                description: "The most powerful rocket ever built",
                                action: {
                                    selectedVehicle = .sls
                                }
                            )
                            
                            VehicleCard(
                                vehicle: .orion,
                                title: "Orion Spacecraft",
                                description: "Next-generation deep space capsule",
                                action: {
                                    selectedVehicle = .orion
                                }
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .sheet(item: $selectedVehicle) { vehicle in
                NavigationStack {
                    ModelViewerView(vehicle: vehicle)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    selectedVehicle = nil
                                }
                            }
                        }
                }
            }
        }
    }
}

struct VehicleCard: View {
    let vehicle: VehicleModel
    let title: String
    let description: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: vehicle == .sls ? "airplane.departure" : "capsule.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ModelSelectionView()
}

