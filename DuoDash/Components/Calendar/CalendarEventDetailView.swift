//
//  CalendarEventDetailView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI
import CoreData

struct CalendarEventDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var event: CalendarEvent
    @ObservedObject var space: SharedSpace
    
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var location: String = ""
    @State private var url: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var isAllDay: Bool = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                
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
                
                // MARK: Löschen
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Termin löschen")
                                .bold()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Termin bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveChanges()
                    }
                    .bold()
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                loadData()
            }
            .alert("Bist du sicher?", isPresented: $showingDeleteAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Löschen", role: .destructive) {
                    deleteEvent()
                }
            } message: {
                Text("Möchtest du diesen Termin wirklich unwiderruflich löschen?")
            }
        }
    }
    
    private func loadData() {
        title = event.title ?? ""
        text = event.text ?? ""
        location = event.location ?? ""
        url = event.url ?? ""
        startDate = event.startDate ?? Date()
        endDate = event.endDate ?? Date()
        isAllDay = event.isAllDay
    }
    
    private func saveChanges() {
        event.title = title
        event.text = text.isEmpty ? nil : text
        event.location = location.isEmpty ? nil : location
        event.url = url.isEmpty ? nil : url
        event.startDate = startDate
        event.endDate = endDate
        event.isAllDay = isAllDay
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
    
    private func deleteEvent() {
        viewContext.delete(event)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Fehler beim Löschen: \(error.localizedDescription)")
        }
    }
}
