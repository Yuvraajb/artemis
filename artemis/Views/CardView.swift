//
//  CardView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

/// Individual card view with flip animation
struct CardView: View {
    let card: ArtemisCard
    @Binding var isSimplifiedMode: Bool
    let isFlipped: Bool

    var body: some View {
        ZStack {
            // Card background
            RoundedRectangle(cornerRadius: 24)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.15, green: 0.15, blue: 0.2),
                            Color(red: 0.1, green: 0.1, blue: 0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)

            // Card content
            if isFlipped {
                CardBackView(
                    card: card,
                    isSimplifiedMode: isSimplifiedMode
                )
            } else {
                CardFrontView(
                    card: card,
                    isSimplifiedMode: isSimplifiedMode
                )
            }
        }
        .frame(height: 500)
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0.5
        )
    }
}

/// Front side of the card
struct CardFrontView: View {
    let card: ArtemisCard
    let isSimplifiedMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Category badge
            HStack {
                Text(card.category.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)

                Spacer()

                if isSimplifiedMode {
                    Image(systemName: "text.bubble")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }

            Spacer()

            // Image or icon
            if let imageName = card.imageName {
                Image(systemName: imageName)
                    .font(.system(size: 60))
                    .foregroundColor(.white.opacity(0.8))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            }

            // Title
            Text(card.title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            // Description
            Text(isSimplifiedMode ? card.simplifiedDescription : card.shortDescription)
                .font(.body)
                .foregroundColor(.gray)
                .lineSpacing(4)
                .multilineTextAlignment(.leading)

            Spacer()

            // Hint text
            HStack {
                Spacer()
                Text("Tap to flip • Long press for simple mode")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
            }
        }
        .padding(24)
    }
}

/// Back side of the card
struct CardBackView: View {
    let card: ArtemisCard
    let isSimplifiedMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Category badge
            HStack {
                Text(card.category.rawValue.capitalized)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)

                Spacer()

                if isSimplifiedMode {
                    Image(systemName: "text.bubble")
                        .foregroundColor(.blue)
                        .font(.caption)
                }
            }

            // Title
            Text(card.title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            // Detailed description
            ScrollView {
                Text(isSimplifiedMode ? card.simplifiedDescription : card.detailedDescription)
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineSpacing(6)
                    .multilineTextAlignment(.leading)
            }

            // Hint text
            HStack {
                Spacer()
                Text("Tap to flip back")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
            }
        }
        .padding(24)
    }
}

#Preview {
    CardView(
        card: ArtemisCard(
            id: UUID(),
            title: "What is Artemis II?",
            shortDescription: "NASA's first crewed mission around the Moon since Apollo.",
            detailedDescription: "Artemis II is the second flight of NASA's Artemis program.",
            simplifiedDescription: "Artemis II sends astronauts around the Moon.",
            imageName: "moon.stars.fill",
            category: .overview
        ),
        isSimplifiedMode: .constant(false),
        isFlipped: false
    )
    .frame(height: 500)
    .padding()
    .preferredColorScheme(.dark)
}

