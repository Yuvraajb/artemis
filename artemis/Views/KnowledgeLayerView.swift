//
//  KnowledgeLayerView.swift
//  artemis
//
//  Knowledge Layer Phase - Progressive learning cards with unlock system
//

import SwiftUI

struct KnowledgeLayerView: View {
    @ObservedObject var missionState: MissionStateManager
    let onComplete: () -> Void
    @State private var selectedCard: LearnCard?
    @State private var viewedCards: Set<UUID> = []
    
    private let cards = LearnCard.sampleCards
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            NavigationStack {
                ScrollView {
                    VStack(spacing: 32) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(.cyan)
                            
                            Text("Knowledge Layer")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("Deep dive into mission concepts and facts")
                                .font(.title3)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                        .padding(.bottom, 20)
                        
                        // Progress indicator
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Learning Progress")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("\(viewedCards.count)/\(cards.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(height: 8)
                                        .cornerRadius(4)
                                    
                                    Rectangle()
                                        .fill(Color.cyan)
                                        .frame(width: geometry.size.width * CGFloat(viewedCards.count) / CGFloat(cards.count), height: 8)
                                        .cornerRadius(4)
                                }
                            }
                            .frame(height: 8)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .padding(.horizontal, 20)
                        
                        // Educational intro
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Explore & Learn")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Swipe through interactive cards to learn about the Artemis mission. Each card unlocks new knowledge about the crew, vehicles, and mission objectives.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.1))
                        )
                        .padding(.horizontal, 20)
                        
                        // Swipeable card stack
                        LearnCardSwipeableStack(
                            cards: cards,
                            onCardTapped: { card in
                                selectedCard = card
                                viewedCards.insert(card.id)
                            },
                            onCardSwiped: { card in
                                viewedCards.insert(card.id)
                            }
                        )
                        .frame(height: 500)
                        .padding(.horizontal, 20)
                        
                        // Complete button
                        Button(action: onComplete) {
                            HStack {
                                Text("Mission Complete!")
                                Image(systemName: "checkmark.circle.fill")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [.cyan, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                }
                .navigationTitle("Knowledge Layer")
                .navigationBarTitleDisplayMode(.inline)
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
        .preferredColorScheme(.dark)
    }
}

#Preview {
    KnowledgeLayerView(missionState: MissionStateManager(), onComplete: {})
}
