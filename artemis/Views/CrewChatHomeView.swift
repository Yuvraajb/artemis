//
//  CrewChatHomeView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

/// Home view for Crew Chat tab - displays astronaut selection grid
struct CrewChatHomeView: View {
    @State private var selectedAstronaut: Astronaut?

    private let astronauts = Astronaut.sampleAstronauts

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark mode background
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Crew Chat")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("Chat with simulated astronaut personas based on public information")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        // Disclaimer
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                                .font(.caption)

                            Text("Simulated persona — educational use only")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)

                        // Astronaut grid
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
                            ForEach(astronauts) { astronaut in
                                AstronautCard(astronaut: astronaut) {
                                    selectedAstronaut = astronaut
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationDestination(item: $selectedAstronaut) { astronaut in
                ChatView(astronaut: astronaut)
            }
            .navigationTitle("Crew Chat")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
    }
}

/// Individual astronaut card component
struct AstronautCard: View {
    let astronaut: Astronaut
    let action: () -> Void
    
    /// Get image filename for astronaut
    private var imageName: String {
        switch astronaut.id {
        case "reid-wiseman":
            return "wiseman"
        case "victor-glover":
            return "glover"
        case "christina-koch":
            return "koch"
        case "jeremy-hansen":
            return "hansen"
        default:
            return "wiseman"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Astronaut image
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())

                // Name
                Text(astronaut.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                // Role tagline
                Text(astronaut.roleTagline)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(astronaut.name)
        .accessibilityHint("Double tap to start a chat")
    }
}

#Preview {
    CrewChatHomeView()
}

