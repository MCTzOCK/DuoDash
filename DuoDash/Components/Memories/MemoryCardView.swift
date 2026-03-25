//
//  MemoryCardView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//
import SwiftUI
import CoreData
import PhotosUI

struct MemoryCardView: View {
    
    @ObservedObject var memory: Memory
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Foto (Falls vorhanden)
            if let photoData = memory.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .clipped()
            }
            
            // Text-Bereich
            VStack(alignment: .leading, spacing: 8) {
                
                // Datum
                if let date = memory.date {
                    Text(formattedDate(date))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                }
                
                // Titel
                Text(memory.title ?? "Erinnerung")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                // Body-Text Vorschau
                if let bodyText = memory.bodyText, !bodyText.isEmpty {
                    Text(bodyText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                }
                
                // Location
                if let location = memory.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 2)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .clipped()
        .contentShape(Rectangle())
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
