//
//  CalendarOverviewView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI
import CoreData

// MARK: - ===========================================
// MARK: - 1. KALENDER ÜBERSICHT (Hauptview)
// MARK: - ===========================================

struct CalendarOverviewView: View {
    
    @ObservedObject var space: SharedSpace
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest var events: FetchedResults<CalendarEvent>
    
    @State private var selectedDate: Date = Date()
    @State private var showingCreateSheet = false
    @State private var eventToEdit: CalendarEvent? = nil
    
    init(space: SharedSpace) {
        self.space = space
        _events = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \CalendarEvent.startDate, ascending: true)],
            predicate: NSPredicate(format: "space == %@", space)
        )
    }
    
    private var eventsForSelectedDate: [CalendarEvent] {
        events.filter { event in
            guard let start = event.startDate else { return false }
            return Calendar.current.isDate(start, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: Custom Kalender mit Event-Dots!
                CustomCalendarGrid(selectedDate: $selectedDate, events: events)
                
                // MARK: Tages-Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(formattedWeekday)
                            .font(.caption)
                            .textCase(.uppercase)
                            .foregroundColor(.secondary)
                        Text(formattedDate)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Button {
                        showingCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal)
                
                // MARK: Event-Liste
                if eventsForSelectedDate.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 44))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                        
                        Text("Keine Termine")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Tippe auf +, um einen gemeinsamen Termin für diesen Tag zu erstellen.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.vertical, 40)
                } else {
                    VStack(spacing: 12) {
                        ForEach(eventsForSelectedDate) { event in
                            Button {
                                eventToEdit = event
                            } label: {
                                CalendarEventRow(event: event)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Kalender")
        .background(Color(UIColor.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateCalendarEventView(space: space, initialDate: selectedDate)
        }
        .sheet(item: $eventToEdit) { event in
            CalendarEventDetailView(event: event, space: space)
        }
    }
    
    private var formattedWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .long
        return formatter.string(from: selectedDate)
    }
}
