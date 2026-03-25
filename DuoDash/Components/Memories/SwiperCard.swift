//
//  SwiperCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//
import SwiftUI
import CoreData
import PhotosUI

struct SwiperCard: View {
    
    @ObservedObject var memory: Memory
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Foto oder Platzhalter
            ZStack(alignment: .bottomLeading) {
                if let photoData = memory.photoData, let uiImage = UIImage(data: photoData) {
                    GeometryReader { geo in
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: 320)
                            .clipped()
                    }
                    .frame(height: 320)
                } else {
                    LinearGradient(
                        colors: [.accentColor.opacity(0.6), .purple.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .frame(height: 320)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.3))
                    )
                }
                
                if let date = memory.date {
                    Text(formattedDate(date))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                        .padding(16)
                }
            }
            // Diese Zeile ist entscheidend: Schneidet alles ab, was über die Karte hinausragt
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 24,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 24
                )
            )
            
            // Text-Bereich
            VStack(alignment: .leading, spacing: 12) {
                Text(memory.title ?? "Erinnerung")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                if let bodyText = memory.bodyText, !bodyText.isEmpty {
                    Text(bodyText)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(5)
                }
                
                if let location = memory.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .padding(.top, 4)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
