//
//  LearnCardDetailView.swift
//  artemis
//
//  Half-screen expandable detail view for Learn Cards
//

import SwiftUI

/// Half-screen expandable detail view for Learn Cards
/// Starts at medium detent and can expand to large (full screen)
struct LearnCardDetailView: View {
    let card: LearnCard
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.black
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // Hero section
                        ZStack(alignment: .leading) {
                            // Background card
                            RoundedRectangle(cornerRadius: 28)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            card.themeColor.opacity(0.3),
                                            card.themeColor.opacity(0.15)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .background(
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(.ultraThinMaterial)
                                )
                                .frame(height: 200)
                            
                            // Content
                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(card.title)
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundColor(.primary)
                                    
                                    Text(card.subtitle)
                                        .font(.system(size: 18, weight: .regular))
                                        .foregroundColor(.secondary)
                                }
                                .padding(.leading, 24)
                                .padding(.trailing, 16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if let imageName = card.imageName {
                                    Image(systemName: imageName)
                                        .font(.system(size: 56, weight: .light))
                                        .foregroundColor(card.themeColor.opacity(0.6))
                                        .frame(width: 100, height: 100)
                                }
                            }
                            .padding(.vertical, 24)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Detail text content
                        VStack(alignment: .leading, spacing: 20) {
                            Text(card.detailText)
                                .font(.body) // Uses Dynamic Type automatically
                                .foregroundColor(.primary)
                                .lineSpacing(6)
                                .padding(.horizontal, 20)
                                .padding(.top, 32)
                        }
                        
                        // Bottom padding
                        Spacer()
                            .frame(height: 60)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    LearnCardDetailView(
        card: LearnCard.sampleCards[0],
        onDismiss: {}
    )
}
