//
//  ArtemisCard.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import Foundation
import Combine

/// Represents a single educational card in the Learn Artemis tab
struct ArtemisCard: Identifiable {
    let id: UUID
    let title: String
    let shortDescription: String
    let detailedDescription: String
    let simplifiedDescription: String
    let imageName: String?
    let imageAssetName: String? // For custom images like sun, moon, etc.
    let category: CardCategory
    
    enum AnimationType {
        case none
        case pulse
        case rotate
    }
    let animationType: AnimationType

    enum CardCategory: String {
        case overview
        case timeline
        case systems
        case crew
    }
}

/// View model for managing Artemis cards
class ArtemisCardViewModel: ObservableObject {
    @Published var cards: [ArtemisCard] = []
    @Published var currentIndex: Int = 0

    init() {
        loadCards()
    }

    private func loadCards() {
        cards = [
            ArtemisCard(
                id: UUID(),
                title: "Artemis II Mission",
                shortDescription: "NASA's first crewed mission around the Moon since Apollo.",
                detailedDescription: """
                Artemis II is the second flight of NASA's Artemis program and the first crewed mission. It will carry four astronauts on a 10-day journey around the Moon and back to Earth.

                This historic mission marks humanity's return to deep space exploration. The crew will travel farther from Earth than any human has gone before, testing critical systems and paving the way for future lunar landings.

                Key Points:
                • First crewed test of the Orion spacecraft
                • Validates life support systems in deep space
                • Tests deep space communication capabilities
                • Prepares for future lunar landings
                • Demonstrates human capability beyond low Earth orbit

                The mission will follow a free-return trajectory around the Moon, allowing the crew to experience the far side of our celestial neighbor before returning safely to Earth.
                """,
                simplifiedDescription: "Artemis II sends astronauts around the Moon to test everything before landing.",
                imageName: "moon.stars.fill",
                imageAssetName: nil,
                category: .overview,
                animationType: .pulse
            ),
            ArtemisCard(
                id: UUID(),
                title: "Space Launch System",
                shortDescription: "The most powerful rocket ever built.",
                detailedDescription: """
                SLS is NASA's super heavy-lift launch vehicle designed for deep space missions. Standing taller than the Statue of Liberty, this behemoth represents the pinnacle of rocket engineering.

                The SLS generates 8.8 million pounds of thrust at liftoff, making it the most powerful rocket ever constructed. Its massive power is essential for sending the Orion spacecraft, crew, and supplies on their journey to the Moon.

                Capabilities:
                • Most powerful rocket in the world
                • Can launch 27+ metric tons to the Moon
                • Uses proven technology from Space Shuttle
                • Designed for crew safety above all else
                • Enables missions beyond low Earth orbit

                As the rocket ascends, it burns through millions of pounds of fuel, creating a brilliant trail of fire and light that illuminates the Florida sky. The roar of its engines can be heard for miles, a testament to the raw power propelling humanity back to the Moon.
                """,
                simplifiedDescription: "SLS is the giant rocket that launches everything into space. It's incredibly powerful.",
                imageName: "airplane.departure",
                imageAssetName: nil,
                category: .systems,
                animationType: .none
            )
        ]
    }

    var currentCard: ArtemisCard? {
        guard currentIndex < cards.count else { return nil }
        return cards[currentIndex]
    }

    func nextCard() {
        if currentIndex < cards.count - 1 {
            currentIndex += 1
        }
    }

    func reset() {
        currentIndex = 0
    }
}

