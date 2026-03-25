//
//  OrganisationView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI
import CoreData

struct OrganisationTabView: View {
    
    @ObservedObject var space: SharedSpace
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // MARK: - Header Bereich
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gemeinsame Planung")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Behaltet eure Termine, Einkäufe und To-Do's an einem zentralen Ort im Blick.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // MARK: - Navigation Cards
                    VStack(spacing: 16) {
                        
                        // 1. Die Listen Karte
                        NavigationLink(destination: ListsOverviewView(space: space)) {
                            OrganisationCard(
                                title: "Geteilte Listen",
                                subtitle: "Einkäufe, To-Do's, Packlisten und mehr. Hake Dinge ab und dein Partner sieht es in Echtzeit.",
                                icon: "checklist",
                                iconColor: .blue
                            )
                        }
                        .buttonStyle(.plain) // Wichtig, damit nicht die ganze Karte blau wird!
                        
                        // 2. Die Kalender Karte
                        NavigationLink(destination: CalendarOverviewView(space: space)) {
                            OrganisationCard(
                                title: "Pärchen-Kalender",
                                subtitle: "Wann ist das nächste Date? Wer kocht am Dienstag? Tragt alle gemeinsamen Termine hier ein.",
                                icon: "calendar",
                                iconColor: .red
                            )
                        }
                        .buttonStyle(.plain)
                        
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("Organisation")
            // Ein leicht abgesetzter Hintergrund, auf dem die weißen Karten perfekt wirken
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}

// MARK: - Wiederverwendbare Karten-Komponente
struct OrganisationCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            // Icon mit typischem Apple-Kreis-Hintergrund
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(iconColor)
                .frame(width: 50, height: 50)
                .background(iconColor.opacity(0.15))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer(minLength: 0)
            
            // Der Chevron-Pfeil (deutet an, dass man klicken kann)
            Image(systemName: "chevron.right")
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .padding(.top, 14)
        }
        .padding()
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(20)
        // Ein Hauch von Schatten für die Tiefe
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Dummy Ziel-Views (Damit der Code direkt läuft)

struct ListsOverviewView: View {
    @ObservedObject var space: SharedSpace
    var body: some View {
        Text("Hier kommen die Listen hin!")
            .navigationTitle("Listen")
    }
}

// MARK: - Preview
#Preview {
    OrganisationTabView(space: SharedSpace())
}
