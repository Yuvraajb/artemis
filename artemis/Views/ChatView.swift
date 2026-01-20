//
//  ChatView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

/// Chat interface for conversing with an astronaut persona
struct ChatView: View {
    let astronaut: Astronaut
    @StateObject private var viewModel: ChatViewModel
    @State private var messageText: String = ""
    @FocusState private var isInputFocused: Bool
    
    /// Get image filename for astronaut
    private var astronautImageName: String {
        switch astronaut.id {
        case "reid-wiseman":
            return "wiseman"
        case "victor-glover":
            return "glover"
        case "christina-koch":
            return "koch"
        case "jeremy-hansen":
            return "hansen"
        default:
            return "wiseman"
        }
    }

    init(astronaut: Astronaut) {
        self.astronaut = astronaut
        _viewModel = StateObject(wrappedValue: ChatViewModel(astronaut: astronaut))
    }

    var body: some View {
        ZStack {
            // Dark mode background
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    // Astronaut image
                    Image(astronautImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())

                    // Name
                    Text(astronaut.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    // Disclaimer
                    Text("Simulated persona — educational use only")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.1, green: 0.1, blue: 0.15))

                Divider()
                    .background(Color.gray.opacity(0.3))

                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageBubble(message: message)
                                    .id(message.id)
                            }
                            
                            // Loading indicator
                            if viewModel.isGenerating {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                        .scaleEffect(0.8)
                                    Text("Thinking...")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer(minLength: 60)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .id("loading")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: viewModel.messages.count) { oldValue, newValue in
                        if let lastMessage = viewModel.messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: viewModel.isGenerating) { oldValue, newValue in
                        if newValue {
                            // Scroll to show loading indicator
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation {
                                    proxy.scrollTo("loading", anchor: .bottom)
                                }
                            }
                        }
                    }
                }

                Divider()
                    .background(Color.gray.opacity(0.3))

                // Input area
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $messageText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.15, green: 0.15, blue: 0.2))
                        .cornerRadius(20)
                        .foregroundColor(.white)
                        .focused($isInputFocused)
                        .lineLimit(1...5)

                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(messageText.isEmpty ? .gray : .blue)
                    }
                    .disabled(messageText.isEmpty || viewModel.isGenerating)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(red: 0.1, green: 0.1, blue: 0.15))
            }
        }
        .navigationTitle(astronaut.name)
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
    }

    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""
        isInputFocused = false
        
        viewModel.sendMessage(userMessage)
    }
}

/// Individual message bubble component
struct MessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.sender == .astronaut {
                Spacer(minLength: 60)
            }

            VStack(alignment: message.sender == .user ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.body)
                    .foregroundColor(message.sender == .user ? .white : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.sender == .user
                            ? Color.blue
                            : Color(red: 0.2, green: 0.2, blue: 0.25)
                    )
                    .cornerRadius(18)

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }

            if message.sender == .user {
                Spacer(minLength: 60)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(astronaut: Astronaut.sampleAstronauts[0])
    }
}

