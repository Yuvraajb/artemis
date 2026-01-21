//
//  LearnCard.swift
//  artemis
//
//  Created for Artemis Learn Cards Stack
//

import Foundation
import SwiftUI

/// Represents a single Learn Card in the Today-tab style stack
struct LearnCard: Identifiable {
    let id: UUID
    let title: String
    let subtitle: String
    let themeColor: Color
    let imageName: String?
    let detailText: String
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        themeColor: Color,
        imageName: String? = nil,
        detailText: String
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.themeColor = themeColor
        self.imageName = imageName
        self.detailText = detailText
    }
}

/// Sample data for Artemis Learn Cards
extension LearnCard {
    static let sampleCards: [LearnCard] = [
        LearnCard(
            title: "Artemis II Crew",
            subtitle: "Meet the four astronauts embarking on humanity's return to the Moon",
            themeColor: .blue,
            imageName: "person.3.fill",
            detailText: """
            The Artemis II crew represents a diverse team of experienced astronauts ready to make history. Commander Reid Wiseman leads the mission, bringing extensive spaceflight experience from his time on the International Space Station.
            
            Pilot Victor Glover brings his test pilot expertise and previous ISS experience to handle Orion's systems. Mission Specialist Christina Koch holds the record for the longest single spaceflight by a woman and brings invaluable long-duration mission experience.
            
            Mission Specialist Jeremy Hansen represents the Canadian Space Agency, marking Canada's first astronaut to travel to the Moon. Together, this crew will validate Orion's systems and pave the way for future lunar landings.
            
            Their mission will test life support systems, deep space communications, and crew procedures during a 10-day journey around the Moon and back to Earth.
            """
        ),
        LearnCard(
            title: "Space Launch System",
            subtitle: "The most powerful rocket ever built, designed for deep space exploration",
            themeColor: .orange,
            imageName: "airplane.departure",
            detailText: """
            The Space Launch System (SLS) is NASA's super heavy-lift launch vehicle, standing taller than the Statue of Liberty. At liftoff, it generates 8.8 million pounds of thrust, making it the most powerful rocket ever constructed.
            
            SLS uses proven technology from the Space Shuttle program, including the RS-25 engines and solid rocket boosters. This heritage technology, combined with modern engineering, creates a reliable and powerful launch system.
            
            The rocket can launch more than 27 metric tons to the Moon, carrying the Orion spacecraft, crew, and essential supplies. Its massive power is essential for missions beyond low Earth orbit, enabling humanity's return to the Moon and future missions to Mars.
            
            As SLS ascends, it creates a brilliant trail of fire and light, with the roar of its engines audible for miles—a testament to the raw power propelling humanity back to the Moon.
            """
        ),
        LearnCard(
            title: "Orion Capsule",
            subtitle: "NASA's next-generation spacecraft built for deep space missions",
            themeColor: .purple,
            imageName: "capsule.fill",
            detailText: """
            The Orion spacecraft is NASA's advanced crew vehicle designed specifically for deep space exploration. It's built to carry astronauts farther from Earth than any previous spacecraft, with advanced life support systems and radiation protection.
            
            Orion features a state-of-the-art heat shield that can withstand temperatures up to 5,000 degrees Fahrenheit during re-entry—hotter than molten lava. This technology is crucial for safe returns from lunar distances.
            
            The capsule can support a crew of four for up to 21 days, with advanced avionics, power systems, and communication capabilities. It's designed to work seamlessly with the Space Launch System and future lunar infrastructure.
            
            On Artemis II, Orion will carry the crew around the Moon, testing all systems in a real deep space environment before future missions land on the lunar surface.
            """
        ),
        LearnCard(
            title: "Mission Timeline",
            subtitle: "A 10-day journey around the Moon and back to Earth",
            themeColor: .cyan,
            imageName: "calendar",
            detailText: """
            Artemis II follows a carefully planned timeline designed to maximize mission objectives while ensuring crew safety. The mission begins with launch from Kennedy Space Center's Launch Complex 39B.
            
            After reaching Earth orbit, the crew will perform systems checks and prepare for the translunar injection burn. This critical maneuver sends Orion on a trajectory toward the Moon using a free-return path that naturally brings the spacecraft back to Earth.
            
            The crew will spend several days traveling to the Moon, testing systems and conducting experiments. As they approach, they'll perform a lunar flyby, coming within a few thousand miles of the lunar surface—closer than any human has been since Apollo 17.
            
            The return journey follows the same free-return trajectory, with the crew monitoring systems and preparing for re-entry. The mission concludes with a splashdown in the Pacific Ocean, where recovery teams will retrieve the crew and spacecraft.
            """
        ),
        LearnCard(
            title: "Lunar Objectives",
            subtitle: "Preparing for humanity's sustainable presence on the Moon",
            themeColor: .indigo,
            imageName: "moon.stars.fill",
            detailText: """
            Artemis II serves as a critical stepping stone toward establishing a sustainable human presence on the Moon. The mission validates systems and procedures needed for future lunar landings and long-term exploration.
            
            Key objectives include testing Orion's life support systems under crewed conditions, validating deep space communication capabilities, and demonstrating crew operations in the deep space environment. These tests are essential before attempting a lunar landing.
            
            The mission also prepares for future Artemis missions that will land astronauts near the Moon's South Pole, where water ice deposits could support long-term exploration. Artemis II proves that humans can operate safely in deep space, paving the way for these ambitious goals.
            
            Beyond the Moon, the lessons learned from Artemis II will inform future missions to Mars and other deep space destinations, making this mission a crucial milestone in humanity's expansion into the solar system.
            """
        )
    ]
}
