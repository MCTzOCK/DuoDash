//
//  ListContainerCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//
import SwiftUI

struct ListContainerCard: View {
    
    @ObservedObject var container: ListContainer
    
    private var allItems: [ListItem] {
        (container.items?.allObjects as? [ListItem]) ?? []
    }
    
    private var completedCount: Int {
        allItems.filter { $0.isCompleted }.count
    }
    
    private var totalCount: Int {
        allItems.count
    }
    
    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // Icon mit farbigem Kreis-Hintergrund
            Image(systemName: container.symbol ?? "list.bullet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.accentColor)
                .frame(width: 44, height: 44)
                .background(Color.accentColor.opacity(0.15))
                .clipShape(Circle())
            
            Spacer(minLength: 4)
            
            // Titel
            Text(container.title ?? "Liste")
                .font(.headline)
                .foregroundColor(.primary)
                .lineLimit(2)
            
            // Fortschritt
            if totalCount > 0 {
                VStack(alignment: .leading, spacing: 6) {
                    // Fortschrittsbalken (wie in Apple Health / Fitness)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.secondary.opacity(0.2))
                                .frame(height: 6)
                            
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.accentColor)
                                .frame(width: geo.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                    
                    Text("\(completedCount) von \(totalCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Keine Einträge")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.tertiaryLabel))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

