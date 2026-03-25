//
//  ListItemRow.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI
import CoreData

struct ListItemRow: View {
    
    @ObservedObject var item: ListItem
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        HStack(spacing: 14) {
            
            // Toggle-Kreis (Antippen erledigt/öffnet)
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    item.isCompleted.toggle()
                    CoreDataManager.shared.save()
                }
            } label: {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(item.isCompleted ? .green : Color(UIColor.tertiaryLabel))
            }
            .buttonStyle(.plain)
            
            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title ?? "Eintrag")
                    .font(.body)
                    .foregroundColor(item.isCompleted ? .secondary : .primary)
                    .strikethrough(item.isCompleted, color: .secondary)
                
                if let text = item.text, !text.isEmpty {
                    Text(text)
                        .font(.caption)
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Kleines Bild-Thumbnail, falls vorhanden
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 36, height: 36)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .font(.caption2)
        }
    }
}
