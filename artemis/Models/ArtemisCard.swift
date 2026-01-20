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
    let category: CardCategory

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
                title: "What is Artemis II?",
                shortDescription: "NASA's first crewed mission around the Moon since Apollo.",
                detailedDescription: """
                Artemis II is the second flight of NASA's Artemis program and the first crewed mission. It will carry four astronauts on a 10-day journey around the Moon and back to Earth.

                Key Points:
                • First crewed test of the Orion spacecraft
                • Validates life support systems
                • Tests deep space communication
                • Prepares for future lunar landings
                """,
                simplifiedDescription: "Artemis II sends astronauts around the Moon to test everything before landing.",
                imageName: "moon.stars.fill",
                category: .overview
            ),
            ArtemisCard(
                id: UUID(),
                title: "Why Artemis Exists",
                shortDescription: "Establishing a sustainable human presence on the Moon.",
                detailedDescription: """
                The Artemis program aims to return humans to the Moon and establish a sustainable presence there.

                Goals:
                • Learn to live and work on another world
                • Test technologies for Mars missions
                • Conduct scientific research
                • Inspire the next generation
                • Create economic opportunities in space
                """,
                simplifiedDescription: "We're going back to the Moon to learn how to live in space and eventually go to Mars.",
                imageName: "globe.americas.fill",
                category: .overview
            ),
            ArtemisCard(
                id: UUID(),
                title: "Artemis Mission Timeline",
                shortDescription: "A multi-phase journey to the Moon and beyond.",
                detailedDescription: """
                The Artemis program unfolds in phases:

                Phase 1 (Artemis I): Uncrewed test flight - Completed 2022
                Phase 2 (Artemis II): Crewed flight around Moon - 2025
                Phase 3 (Artemis III): First crewed landing - 2026
                Phase 4+: Sustainable lunar presence

                Each phase builds on the previous, testing systems and building infrastructure.
                """,
                simplifiedDescription: "First we test, then we fly with crew, then we land. Step by step.",
                imageName: "calendar",
                category: .timeline
            ),
            ArtemisCard(
                id: UUID(),
                title: "Orion Spacecraft",
                shortDescription: "NASA's next-generation crew vehicle for deep space.",
                detailedDescription: """
                The Orion spacecraft is designed to carry astronauts to the Moon and beyond.

                Features:
                • Life support for 21 days
                • Advanced navigation systems
                • Heat shield for Earth re-entry
                • Can carry up to 4 astronauts
                • Built for deep space missions

                Orion will serve as the command module for Artemis missions.
                """,
                simplifiedDescription: "Orion is the spaceship that carries astronauts safely to the Moon and back.",
                imageName: "airplane",
                category: .systems
            ),
            ArtemisCard(
                id: UUID(),
                title: "Space Launch System (SLS)",
                shortDescription: "The most powerful rocket ever built.",
                detailedDescription: """
                SLS is NASA's super heavy-lift launch vehicle designed for deep space missions.

                Capabilities:
                • Most powerful rocket in the world
                • Can launch 27+ metric tons to the Moon
                • Uses proven technology from Space Shuttle
                • Designed for crew safety
                • Enables missions beyond low Earth orbit

                SLS provides the power needed to send Orion and supplies to the Moon.
                """,
                simplifiedDescription: "SLS is the giant rocket that launches everything into space. It's incredibly powerful.",
                imageName: "airplane.departure",
                category: .systems
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

