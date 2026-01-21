//
//  LearnCardSwipeableStack.swift
//  artemis
//
//  Tinder-style swipeable card stack for Learn Cards
//

import SwiftUI

/// Tinder-style swipeable card stack for Learn Cards
struct LearnCardSwipeableStack: View {
    let cards: [LearnCard]
    @State private var currentIndex: Int = 0
    let onCardTapped: (LearnCard) -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var rotationAngle: Double = 0
    
    // Constants
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15
    private let maxPreviewCards = 2 // Show up to 2 cards behind current
    
    // Helper to get card at index with wrapping
    private func card(at index: Int) -> LearnCard {
        guard !cards.isEmpty else { fatalError("Cards array cannot be empty") }
        return cards[index % cards.count]
    }
    
    var currentCard: LearnCard? {
        guard !cards.isEmpty else { return nil }
        return card(at: currentIndex)
    }
    
    var body: some View {
        ZStack {
            // Solid opaque background to prevent see-through
            Color.black
                .ignoresSafeArea()
            
            if let currentCard = currentCard {
                // Background preview cards (showing actual next cards with wrapping)
                ForEach(0..<maxPreviewCards, id: \.self) { offset in
                    let previewIndex = (currentIndex + offset + 1) % cards.count
                    LearnCardTinderView(
                        card: card(at: previewIndex),
                        onTap: nil // Preview cards are not tappable
                    )
                    .scaleEffect(0.95 - CGFloat(offset) * 0.03)
                    .offset(y: CGFloat(offset + 1) * 8)
                    .opacity(1.0 - Double(offset) * 0.05) // Nearly fully opaque instead of semi-transparent
                    .zIndex(Double(maxPreviewCards - offset))
                }
                
                // Top interactive card
                LearnCardTinderView(
                    card: currentCard,
                    onTap: {
                        onCardTapped(currentCard)
                    }
                )
                .offset(dragOffset)
                .rotationEffect(.degrees(rotationAngle))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragOffset = value.translation
                            rotationAngle = Double(value.translation.width / 10).clamped(to: -maxRotation...maxRotation)
                        }
                        .onEnded { value in
                            let dragDistance = abs(value.translation.width)
                            
                            if dragDistance > swipeThreshold {
                                // Swipe away - faster animation
                                withAnimation(.spring(response: 0.2, dampingFraction: 0.7)) {
                                    dragOffset = CGSize(
                                        width: value.translation.width > 0 ? 1000 : -1000,
                                        height: value.translation.height
                                    )
                                    rotationAngle = value.translation.width > 0 ? maxRotation : -maxRotation
                                }
                                
                                // Smooth transition to next card
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    nextCard()
                                    resetCard()
                                }
                            } else {
                                // Snap back
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    dragOffset = .zero
                                    rotationAngle = 0
                                }
                            }
                        }
                )
                .zIndex(10)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func nextCard() {
        guard !cards.isEmpty else { return }
        currentIndex = (currentIndex + 1) % cards.count
    }
    
    private func resetCard() {
        dragOffset = .zero
        rotationAngle = 0
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

/// Tinder-style card view for Learn Cards
struct LearnCardTinderView: View {
    let card: LearnCard
    let onTap: (() -> Void)?
    
    var body: some View {
        ZStack {
            // Card background - solid base with gradient overlay
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(red: 0.12, green: 0.12, blue: 0.16)) // Solid opaque base color
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    card.themeColor.opacity(0.6),  // Increased from 0.4
                                    card.themeColor.opacity(0.3),  // Increased from 0.2
                                    Color(red: 0.12, green: 0.12, blue: 0.16) // More visible dark color
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.15), lineWidth: 1) // Slightly more visible border
                )
                .shadow(color: .black.opacity(0.5), radius: 15, x: 0, y: 8)
            
            // Card content
            VStack(alignment: .leading, spacing: 0) {
                // Top section - Title
                VStack(alignment: .leading, spacing: 8) {
                    Text(card.title)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Rectangle()
                        .fill(card.themeColor)
                        .frame(width: 30, height: 2)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                
                Spacer()
                
                // Center section - Icon
                if let imageName = card.imageName {
                    Image(systemName: imageName)
                        .font(.system(size: 120))
                        .foregroundColor(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
                
                // Bottom section - Subtitle
                VStack(alignment: .leading, spacing: 12) {
                    Text(card.subtitle)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .frame(height: 600)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

#Preview {
    LearnCardSwipeableStack(
        cards: LearnCard.sampleCards,
        onCardTapped: { _ in }
    )
    .background(Color.black)
    .preferredColorScheme(.dark)
}
