//
//  LatestMemoryCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//
import SwiftUI


struct LatestMemoryCard: View {
    @ObservedObject var space: SharedSpace
    
    private var latestMemory: Memory? {
        let all = (space.memories?.allObjects as? [Memory]) ?? []
        return all.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }.first
    }
    
    var body: some View {
        if let memory = latestMemory {
            VStack(spacing: 0) {
                // Foto
                if let imgData = memory.photoData, let uiImage = UIImage(data: imgData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 160)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .overlay(
                            // Gradient-Overlay für Lesbarkeit
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            // Text auf dem Foto
                            VStack(alignment: .leading, spacing: 4) {
                                Spacer()
                                Text("Letzte Erinnerung")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                Text(memory.title ?? "")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        )
                } else {
                    // Ohne Foto
                    HStack {
                        Image(systemName: "photo.on.rectangle.angled")
                            .foregroundColor(.purple)
                            .font(.headline)
                        Text("Letzte Erinnerung")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Text unter dem Foto
                if let bodyText = memory.bodyText, !bodyText.isEmpty {
                    Text(bodyText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(20)
            .clipped()
            .padding(.horizontal)
        }
    }
}
