//
//  MissionPhaseView.swift
//  artemis
//
//  Router view that displays the appropriate view for each mission phase
//

import SwiftUI

struct MissionPhaseView: View {
    let phase: MissionPhase
    @ObservedObject var missionState: MissionStateManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            switch phase {
            case .briefing:
                MissionBriefingView(missionState: missionState, onComplete: {
                    missionState.completePhase(.briefing)
                })
            case .vehicleSystems:
                VehicleSystemsView(missionState: missionState, onComplete: {
                    missionState.completePhase(.vehicleSystems)
                })
            case .crewInteraction:
                CrewInteractionView(missionState: missionState, onComplete: {
                    missionState.completePhase(.crewInteraction)
                })
            case .missionSimulation:
                MissionSimulationView(missionState: missionState, onComplete: {
                    missionState.completePhase(.missionSimulation)
                })
            case .knowledgeLayer:
                KnowledgeLayerView(missionState: missionState, onComplete: {
                    missionState.completePhase(.knowledgeLayer)
                })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
