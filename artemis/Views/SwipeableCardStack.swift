//
//  SwipeableCardStack.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

/// Swipeable card stack component with drag gestures
struct SwipeableCardStack: View {
    let card: ArtemisCard
    @Binding var isSimplifiedMode: Bool
    let onDismiss: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var rotationAngle: Double = 0
    @State private var isFlipped: Bool = false

    // Constants
    private let swipeThreshold: CGFloat = 100
    private let maxRotation: Double = 15

    var body: some View {
        ZStack {
            // Background cards (stacked effect)
            ForEach(0..<3) { index in
                if index > 0 {
                    CardView(
                        card: card,
                        isSimplifiedMode: $isSimplifiedMode,
                        isFlipped: isFlipped
                    )
                    .scaleEffect(1.0 - CGFloat(index) * 0.05)
                    .offset(y: CGFloat(index) * 8)
                    .opacity(0.5 - Double(index) * 0.15)
                    .zIndex(Double(3 - index))
                }
            }

            // Top interactive card
            CardView(
                card: card,
                isSimplifiedMode: $isSimplifiedMode,
                isFlipped: isFlipped
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
                            // Swipe away
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                dragOffset = CGSize(
                                    width: value.translation.width > 0 ? 1000 : -1000,
                                    height: value.translation.height
                                )
                                rotationAngle = value.translation.width > 0 ? maxRotation : -maxRotation
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onDismiss()
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
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                            isFlipped.toggle()
                        }
                    }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isSimplifiedMode.toggle()
                        }
                    }
            )
            .zIndex(10)
        }
        .padding(.horizontal, 20)
    }

    private func resetCard() {
        dragOffset = .zero
        rotationAngle = 0
        isFlipped = false
    }
}

extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        return min(max(self, range.lowerBound), range.upperBound)
    }
}

#Preview {
    SwipeableCardStack(
        card: ArtemisCard(
            id: UUID(),
            title: "Test Card",
            shortDescription: "Test description",
            detailedDescription: "Detailed test",
            simplifiedDescription: "Simple test",
            imageName: "moon.stars.fill",
            category: .overview
        ),
        isSimplifiedMode: .constant(false),
        onDismiss: {}
    )
    .preferredColorScheme(.dark)
}

