//
//  LearnArtemisView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

/// Main view for the Learn Artemis tab
struct LearnArtemisView: View {
    @StateObject private var viewModel = ArtemisCardViewModel()
    @State private var isSimplifiedMode = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark mode background
                Color.black.ignoresSafeArea()

                if let currentCard = viewModel.currentCard {
                    SwipeableCardStack(
                        card: currentCard,
                        isSimplifiedMode: $isSimplifiedMode,
                        onDismiss: {
                            viewModel.nextCard()
                        }
                    )
                } else {
                    // All cards completed
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)

                        Text("You've explored all the cards!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)

                        Button(action: {
                            viewModel.reset()
                        }) {
                            Text("Start Over")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .navigationTitle("Learn Artemis")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    LearnArtemisView()
}

