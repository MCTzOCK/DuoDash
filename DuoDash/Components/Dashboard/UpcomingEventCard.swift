//
//  UpcomingEventCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//
import SwiftUI


struct UpcomingEventCard: View {
    @ObservedObject var space: SharedSpace
    
    private var nextEvent: CalendarEvent? {
        let all = (space.calendarEvents?.allObjects as? [CalendarEvent]) ?? []
        return all
            .filter { ($0.startDate ?? .distantPast) > Date() }
            .sorted { ($0.startDate ?? .distantFuture) < ($1.startDate ?? .distantFuture) }
            .first
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: "calendar")
                .font(.title2)
                .foregroundColor(.red)
                .frame(width: 40, height: 40)
                .background(Color.red.opacity(0.12))
                .clipShape(Circle())
            
            Spacer()
            
            if let event = nextEvent {
                Text(event.title ?? "Termin")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text(shortDate(event.startDate ?? Date()))
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Keine")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                
                Text("Termine geplant")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20)
    }
    
    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "d. MMM, HH:mm"
        return formatter.string(from: date)
    }
}
