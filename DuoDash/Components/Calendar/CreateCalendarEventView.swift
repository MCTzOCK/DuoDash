//
//  CreateCalendarEventView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI
import CoreData

struct CreateCalendarEventView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var location: String = ""
    @State private var url: String = ""
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay: Bool = false
    
    @ObservedObject var space: SharedSpace
    
    init(space: SharedSpace, initialDate: Date = Date()) {
        self.space = space
        _startDate = State(initialValue: initialDate)
        _endDate = State(initialValue: initialDate.addingTimeInterval(3600))
    }
    
    init(space: SharedSpace, dateIdea: DateIdea) {
        self.space = space
        _title = State(initialValue: dateIdea.title ?? "")
        _text = State(initialValue: dateIdea.text ?? "")
        _location = State(initialValue: dateIdea.location ?? "")
        _url = State(initialValue: dateIdea.urlString ?? "")
        _startDate = State(initialValue: Date())
        _endDate = State(initialValue: Date().addingTimeInterval(3600))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            Form {
                // MARK: Header
                Section {
                    VStack {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("Neuer Termin")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Plane einen gemeinsamen Termin mit deinem Partner!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden, edges: .all)
                
                // MARK: Details
                Section(header: Text("Details")) {
                    TextField("Titel", text: $title)
                        .font(.headline)
                    
                    TextField("Beschreibung", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Toggle(isOn: $isAllDay) {
                        Label("Ganztägig", systemImage: "sun.max.fill")
                    }
                    .tint(.accentColor)
                }
                
                // MARK: Ort & Web
                Section(header: Text("Ort & Web")) {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        TextField("Ort", text: $location)
                    }
                    
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        TextField("URL", text: $url)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                    }
                }
                
                // MARK: Zeitraum
                Section(header: Text("Zeitraum")) {
                    DatePicker(
                        "Beginn",
                        selection: $startDate,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                    
                    DatePicker(
                        "Ende",
                        selection: $endDate,
                        in: startDate...,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )
                }
            }
            
            // MARK: Buttons
            VStack(spacing: 16) {
                Button {
                    saveNewEvent()
                } label: {
                    Text("Termin erstellen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(title.isEmpty ? Color.accentColor.opacity(0.5) : Color.accentColor)
                        .cornerRadius(12)
                }
                .disabled(title.isEmpty)
                
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                        .foregroundStyle(.gray)
                        .bold()
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    private func saveNewEvent() {
        let newEvent = CalendarEvent(context: viewContext)
        newEvent.id = UUID()
        newEvent.title = title
        newEvent.text = text.isEmpty ? nil : text
        newEvent.location = location.isEmpty ? nil : location
        newEvent.url = url.isEmpty ? nil : url
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.isAllDay = isAllDay
        newEvent.space = space
        
        do {
            CoreDataManager.shared.save()
            dismiss()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
}
