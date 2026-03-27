//
//  ListsSummaryCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//
import SwiftUI


struct ListsSummaryCard: View {
    @ObservedObject var space: SharedSpace
    
    private var allContainers: [ListContainer] {
        (space.lists?.allObjects as? [ListContainer]) ?? []
    }
    
    private var totalOpen: Int {
        allContainers.flatMap { ($0.items?.allObjects as? [ListItem]) ?? [] }
            .filter { !$0.isCompleted }.count
    }
    
    private var totalDone: Int {
        allContainers.flatMap { ($0.items?.allObjects as? [ListItem]) ?? [] }
            .filter { $0.isCompleted }.count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "checklist")
                .font(.title2)
                .foregroundColor(.accent)
                .frame(width: 40, height: 40)
                .background(Color.accent.opacity(0.12))
                .clipShape(Circle())
            
            Spacer()
            
            Text("\(totalOpen)")
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
            
            Text("Offene Einträge")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Mini-Fortschrittsbalken
            if totalOpen + totalDone > 0 {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.accent)
                            .frame(width: geo.size.width * (Double(totalDone) / Double(totalOpen + totalDone)), height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20)
    }
}
