//
//  ContentView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

struct ContentView: View {
    @State private var showMissionFlow = false
    
    var body: some View {
        if showMissionFlow {
            MissionFlowView(onDismiss: {
                showMissionFlow = false
            })
        } else {
            HomeView(showMissionFlow: $showMissionFlow)
        }
    }
}

#Preview {
    ContentView()
}
