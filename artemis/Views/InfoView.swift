//
//  InfoView.swift
//  artemis
//
//  Created by Yuvraaj Bhatter on 1/19/26.
//

import SwiftUI

/// Info View: Displays app information and 3D model credits
struct InfoView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark mode background
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // App Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Artemis")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)

                            Text("3D & AR Space Exploration")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 20)

                        Divider()
                            .background(Color.gray.opacity(0.3))

                        // 3D Model Credits
                        VStack(alignment: .leading, spacing: 16) {
                            Text("3D Model Credits")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 12) {
                                Text("Space Launch System (SLS)")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text("Model by Clarence365")
                                    .font(.body)
                                    .foregroundColor(.gray)

                                Link(
                                    destination: URL(string: "https://skfb.ly/ot97t")!,
                                    label: {
                                        HStack {
                                            Text("View on Sketchfab")
                                                .font(.body)
                                                .foregroundColor(.blue)
                                            Image(systemName: "arrow.up.right.square")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                )

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("License:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)

                                    Text("Creative Commons Attribution")
                                        .font(.subheadline)
                                        .foregroundColor(.white)

                                    Link(
                                        destination: URL(string: "http://creativecommons.org/licenses/by/4.0/")!,
                                        label: {
                                            HStack {
                                                Text("View License")
                                                    .font(.subheadline)
                                                    .foregroundColor(.blue)
                                                Image(systemName: "arrow.up.right.square")
                                                    .font(.caption2)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                    )
                                }
                                .padding(.top, 8)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(red: 0.15, green: 0.15, blue: 0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }

                        Divider()
                            .background(Color.gray.opacity(0.3))

                        // App Information
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)

                            Text("Explore NASA's Space Launch System (SLS) rocket in stunning 3D detail. View the model in 3D or place it in your environment using AR.")
                                .font(.body)
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }

                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    InfoView()
}

