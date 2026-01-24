//
//  LearnArtemisView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

/// Main view for the Learn Artemis tab
/// Uses Tinder-style swipeable Learn Cards Stack
struct LearnArtemisView: View {
    @State private var selectedCard: LearnCard?
    
    // Sample cards data - in production, this could come from a view model
    private let cards = LearnCard.sampleCards

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark mode background
                Color.black.ignoresSafeArea()

                // Tinder-style swipeable card stack
                LearnCardSwipeableStack(
                    cards: cards,
                    onCardTapped: { card in
                        selectedCard = card
                    },
                    onCardSwiped: nil
                )
            }
            .navigationTitle("Learn Artemis")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
            .sheet(item: $selectedCard) { card in
                LearnCardDetailView(
                    card: card,
                    onDismiss: {
                        selectedCard = nil
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    LearnArtemisView()
}

