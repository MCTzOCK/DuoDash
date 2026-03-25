//
//  UsView.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI

struct UsView: View {
    
    @ObservedObject var space: SharedSpace
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                NavigationLink(destination: Text("Love Notes View")) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "heart.text.square.fill")
                                .font(.title)
                                .foregroundStyle(.pink)
                            
                            Text("Love Notes")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Hinterlasse eine kleine Nachricht für den Tag.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemFill))
                    .cornerRadius(20)
                }
                .buttonStyle(.plain) // Verhindert, dass der ganze Text blau wird
                
                // 2. DAS GRID: Countdowns & Dates (2 Spalten)
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    
                    // Kachel links: Countdowns
                    DashboardCard(
                        title: "Countdowns",
                        subtitle: "Vorfreude teilen",
                        icon: "hourglass",
                        iconColor: .orange,
                        destination: CountdownOverviewView(space: space)
                    )
                    
                    // Kachel rechts: Date-Ideen
                    DashboardCard(
                        title: "Dates",
                        subtitle: "Bucket List",
                        icon: "wineglass",
                        iconColor: .pink,
                        destination: DateOverviewView(space: space)
                    )
                }
                
                // 3. BOTTOM CARD: Memories (Volle Breite)
                NavigationLink(destination: MemoryOverviewView(space: space)) {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.title)
                                .foregroundStyle(.purple)
                            
                            Text("Memories")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Unsere schönsten Momente und Fotos.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(Color(.tertiaryLabel))
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemFill))
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
                
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .navigationTitle("Wir Zwei")
    }
}

// MARK: - Wiederverwendbare Karten-Komponente für das Grid
struct DashboardCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading, spacing: 16) {
                
                // Icon mit leicht farbigem, runden Hintergrund (Typischer Apple Health/Settings Look)
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(iconColor)
                    .frame(width: 44, height: 44)
                    .background(iconColor.opacity(0.15))
                    .clipShape(Circle())
                
                Spacer(minLength: 10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}
