//
//  DateCardView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI
import CoreData

struct DateCardView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) private var openURL // Um Links und Maps sauber zu öffnen
    
    @ObservedObject var dateIdea: DateIdea
    @ObservedObject var space: SharedSpace
    
    @State private var showAddToCalendar = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - 1. Bild-Sektion (Oben)
            if let imageData = dateIdea.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    // Ca. 40% der Karte: Ein festes Maß oder eine AspectRatio funktionieren hier am besten
                    .frame(height: 180)
                    .frame(maxWidth: .infinity)
                    .clipped()
                    // Leichtes Ausgrauen, wenn das Date schon erledigt ist
                    .opacity(dateIdea.isDone ? 0.6 : 1.0)
            }
            
            // MARK: - 2. Content-Sektion (Mitte)
            VStack(alignment: .leading, spacing: 12) {
                
                // Titel & Preislevel
                HStack(alignment: .top) {
                    Text(dateIdea.title ?? "Neue Idee")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(dateIdea.isDone ? .secondary : .primary)
                        .strikethrough(dateIdea.isDone, color: .secondary)
                    
                    Spacer()
                    
                    // Zeigt €€€ basierend auf dem priceLevel (1-3)
                    if dateIdea.priceLevel > 0 {
                        Text(String(repeating: "€", count: Int(dateIdea.priceLevel)))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                            .strikethrough(dateIdea.isDone, color: .secondary)
                            .padding(.top, 2)
                    }
                }
                
                // Beschreibung / Text
                if let text = dateIdea.text, !text.isEmpty {
                    Text(text)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Links (Location & URL)
                if hasLinks {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        // Apple Maps Link
                        if let location = dateIdea.location, !location.isEmpty {
                            Button(action: { openAppleMaps(for: location) }) {
                                Label(location, systemImage: "pin.fill")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.accent)
                            }
                        }
                        
                        // Website URL
                        if let urlString = dateIdea.urlString, let url = URL(string: urlString) {
                            Link(destination: url) {
                                Label(urlString.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "www.", with: ""), systemImage: "safari.fill")
                                    .font(.footnote)
                                    .fontWeight(.medium)
                                    .foregroundColor(.accent)
                                    .lineLimit(1)
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            
            // MARK: - 3. Action-Buttons (Unten)
            VStack(spacing: 0) {
                Divider() // Feine Trennlinie wie in Apple Standard-UIs
                
                HStack {
                    // Bearbeiten
                    NavigationLink(destination: DateDetailView(dateIdea: dateIdea, space: space)) {
                        Image(systemName: "pencil")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.accent)
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    // Löschen
                    Button(action: {
                        deleteIdea()
                    }) {
                        Image(systemName: "trash")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.red)
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    // Als erledigt markieren
                    Button(action: {
                        toggleDone()
                    }) {
                        Image(systemName: dateIdea.isDone ? "checkmark.circle.fill" : "circle")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(dateIdea.isDone ? .accent : .gray)
                    }
                    
                    Divider()
                        .frame(height: 20)
                    
                    Button(action: {
                        showAddToCalendar = true
                    }) {
                        Image(systemName: "calendar.badge.plus")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(.accent)
                    }
                }
                .font(.system(size: 18, weight: .medium))
                .padding(.vertical, 12)
            }
            .background(Color(UIColor.tertiarySystemBackground)) // Setzt den Button-Bereich farblich ganz leicht ab
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .clipped()
        .contentShape(Rectangle())
        // Eleganter, weicher Schatten
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .padding(.horizontal)
        .padding(.vertical, 8)
        .sheet(isPresented: $showAddToCalendar) {
            CreateCalendarEventView(space: space, dateIdea: dateIdea)
        }
    }
    
    // MARK: - Hilfsfunktionen
    
    private var hasLinks: Bool {
        let hasLocation = dateIdea.location != nil && !dateIdea.location!.isEmpty
        let hasUrl = dateIdea.urlString != nil && !dateIdea.urlString!.isEmpty
        return hasLocation || hasUrl
    }
    
    private func openAppleMaps(for query: String) {
        // Encodiert den String (z.B. Leerzeichen zu %20), damit die URL gültig ist
        if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let mapURL = URL(string: "maps://?q=\(encodedQuery)") {
            openURL(mapURL)
        }
    }
    
    private func toggleDone() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            dateIdea.isDone.toggle()
            saveContext()
        }
    }
    
    private func deleteIdea() {
        withAnimation {
            viewContext.delete(dateIdea)
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            CoreDataManager.shared.save()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
}
