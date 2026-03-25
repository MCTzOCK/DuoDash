//
//  Untitled.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI


struct CalendarEventRow: View {
    
    @ObservedObject var event: CalendarEvent
    
    var body: some View {
        HStack(spacing: 14) {
            
            RoundedRectangle(cornerRadius: 4)
                .fill(event.isAllDay ? Color.orange : Color.accentColor)
                .frame(width: 5)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title ?? "Kein Titel")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if event.isAllDay {
                    Text("Ganztägig")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                } else {
                    Text(timeRangeString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // NEU: Location anzeigen, falls vorhanden
                if let location = event.location, !location.isEmpty {
                    Label(location, systemImage: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(14)
    }
    
    private var timeRangeString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.timeStyle = .short
        
        guard let start = event.startDate else { return "" }
        let startStr = formatter.string(from: start)
        
        if let end = event.endDate {
            let endStr = formatter.string(from: end)
            return "\(startStr) – \(endStr)"
        }
        return startStr
    }
}
