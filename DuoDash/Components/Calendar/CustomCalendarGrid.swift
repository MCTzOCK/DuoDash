//
//  CustomCalendarGrid.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI

struct CustomCalendarGrid: View {
    
    @Binding var selectedDate: Date
    let events: FetchedResults<CalendarEvent>
    
    @State private var displayedMonth: Date = Date()
    
    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.locale = Locale(identifier: "de_DE")
        cal.firstWeekday = 2 // Montag
        return cal
    }()
    
    private let dayLabels = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(spacing: 14) {
            
            // MARK: Monats-Navigation
            HStack {
                Button { changeMonth(by: -1) } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.headline)
                
                Spacer()
                
                Button { changeMonth(by: 1) } label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 8)
            
            // MARK: Wochentag-Header
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(dayLabels, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // MARK: Tage-Grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(generateDays().enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasEvent: hasEvent(on: date)
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                selectedDate = date
                            }
                        }
                    } else {
                        // Leere Zelle für Tage vor dem Monatsbeginn
                        Text("")
                            .frame(height: 44)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .padding(.horizontal)
        // Wenn sich der ausgewählte Tag ändert, springe zum richtigen Monat
        .onChange(of: selectedDate) { newValue in
            displayedMonth = newValue
        }
    }
    
    // MARK: Hilfsfunktionen
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "LLLL yyyy"
        return formatter.string(from: displayedMonth).capitalized
    }
    
    private func changeMonth(by value: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: value, to: displayedMonth) {
            withAnimation(.easeInOut(duration: 0.2)) {
                displayedMonth = newMonth
            }
        }
    }
    
    /// Generiert ein Array von optionalen Dates für den angezeigten Monat.
    /// `nil` = leere Zelle (Padding vor dem 1.)
    private func generateDays() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth) else { return [] }
        
        let firstDayOfMonth = monthInterval.start
        let weekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        // Offset berechnen (Montag = 0, Dienstag = 1, ..., Sonntag = 6)
        let offset = (weekday + 5) % 7
        
        guard let daysInMonth = calendar.range(of: .day, in: .month, for: displayedMonth)?.count else { return [] }
        
        var days: [Date?] = Array(repeating: nil, count: offset)
        
        for day in 0..<daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day, to: firstDayOfMonth) {
                days.append(date)
            }
        }
        
        return days
    }
    
    /// Prüft, ob an einem bestimmten Tag mindestens ein Event existiert
    private func hasEvent(on date: Date) -> Bool {
        events.contains { event in
            guard let start = event.startDate else { return false }
            return calendar.isDate(start, inSameDayAs: date)
        }
    }
}

// MARK: - Einzelne Tages-Zelle
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvent: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.system(.body, design: .rounded))
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(foregroundColor)
                .frame(width: 36, height: 36)
                .background(backgroundColor)
                .clipShape(Circle())
            
            // DER EVENT-DOT (Das Herzstück!)
            Circle()
                .fill(dotColor)
                .frame(width: 6, height: 6)
                .opacity(hasEvent ? 1 : 0) // Unsichtbar wenn kein Event
        }
        .frame(height: 44)
    }
    
    private var foregroundColor: Color {
        if isSelected { return .white }
        if isToday { return .accentColor }
        return .primary
    }
    
    private var backgroundColor: Color {
        if isSelected { return .accentColor }
        return .clear
    }
    
    private var dotColor: Color {
        if isSelected { return .white }
        return .accentColor
    }
}

