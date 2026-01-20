//
//  ChatViewModel.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import Foundation
import Combine

/// View model for managing chat state and interactions
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isGenerating: Bool = false

    private let astronaut: Astronaut
    private let llmManager: LLMManager

    init(astronaut: Astronaut) {
        self.astronaut = astronaut
        self.llmManager = LLMManager.shared
        
        // Add welcome message
        addWelcomeMessage()
    }

    private func addWelcomeMessage() {
        let welcomeText = """
        Hello! I'm a simulated persona inspired by \(astronaut.name)'s public career. 
        I'm here to help you learn about space exploration and the Artemis missions. 
        What would you like to know?
        """
        let welcomeMessage = ChatMessage(sender: .astronaut, text: welcomeText)
        messages.append(welcomeMessage)
    }

    func sendMessage(_ text: String) {
        // Add user message
        let userMessage = ChatMessage(sender: .user, text: text)
        messages.append(userMessage)

        // Generate response
        isGenerating = true
        
        Task {
            // Add realistic delay for response generation
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            do {
                let response = try await generateResponse(for: text)
                let astronautMessage = ChatMessage(sender: .astronaut, text: response)
                
                await MainActor.run {
                    messages.append(astronautMessage)
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    let errorMessage = ChatMessage(
                        sender: .astronaut,
                        text: "I'm sorry, I'm having trouble responding right now. Please try again."
                    )
                    messages.append(errorMessage)
                    isGenerating = false
                }
            }
        }
    }

    private func generateResponse(for userMessage: String) async throws -> String {
        // System instructions are already set in the Foundation Models session
        // Just pass the user message directly
        let fullPrompt = "User: \(userMessage)\n\nAssistant:"
        
        // Generate response using LLM manager with astronaut-specific Foundation Models session
        return try await llmManager.generateResponse(for: astronaut, prompt: fullPrompt)
    }
}

