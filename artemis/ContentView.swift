//
//  ContentView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ModelSelectionView()
                .tabItem {
                    Label("3D Models", systemImage: "cube")
                }

            LearnArtemisView()
                .tabItem {
                    Label("Learn", systemImage: "sparkles")
                }

            CrewChatHomeView()
                .tabItem {
                    Label("Crew Chat", systemImage: "message.fill")
                }

            InfoView()
                .tabItem {
                    Label("Info", systemImage: "info.circle")
                }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}
