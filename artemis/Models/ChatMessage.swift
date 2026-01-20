//
//  ChatMessage.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import Foundation

/// Represents a single chat message
struct ChatMessage: Identifiable {
    let id: UUID
    let sender: Sender
    let text: String
    let timestamp: Date

    enum Sender {
        case user
        case astronaut
    }

    init(sender: Sender, text: String, timestamp: Date = Date()) {
        self.id = UUID()
        self.sender = sender
        self.text = text
        self.timestamp = timestamp
    }
}

