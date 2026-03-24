//
//  CountdownOverview.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI
import CoreData

struct CountdownOverviewView: View {
    
    @Environment(\.managedObjectContext) var viewContext
    
    @ObservedObject var space: SharedSpace
    
    @State private var showingAddCountdownSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ForEach(space.countdowns?.allObjects as! [Countdown]) { countdown in
                    NavigationLink(destination: CountdownDetailView(space: space, countdown: countdown)) {
                        CountdownRow(countdown: countdown)
                    }
                }
                if space.countdowns?.allObjects.count == 0 {
                    ContentUnavailableView {
                        Label("Keine Countdowns", systemImage: "tray.fill")
                    } description: {
                        VStack(spacing: 20) {
                            Text("Es wurden keine Countdowns erstellt. Tippe auf das Plus-Symbol, um deinen ersten Countdown zu erstellen.")
                            Button() {
                                showingAddCountdownSheet = true
                            } label: {
                                Text("Countdown erstellen")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.accent)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
            .padding(10)
        }
        .navigationTitle("Unsere Countdowns")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    showingAddCountdownSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCountdownSheet) {
            CreateCountdownView(space: space)
        }
    }
}

struct CountdownRow: View {
    
    let countdown: Countdown
    
    @ViewBuilder
    fileprivate var title: some View {
        if let title = countdown.title, !title.isEmpty {
            Text(title)
                .font(.title)
                .bold()
                .foregroundStyle(.white)
        } else {
            Text("Unbenannter Countdown")
                .font(.headline)
                .foregroundStyle(.white)
        }
    }
    @ViewBuilder
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            ZStack {
                // Rounded rectangle with blured image as background, title and countdown on foreground
                GeometryReader { geometry in
                    if let imageData = countdown.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .clipped()
                            .blur(radius: 3)
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                HStack {
                    title
                    Spacer()
                    
                    Text(countdown.targetDate.map { CountdownRow.formattedTimeRemaining(until: $0) } ?? "—")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.trailing, 16)
                    
                    
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                
            }
        }
    }
    
    
    private static func formattedTimeRemaining(until targetDate: Date) -> String {
        let now = Date()
        guard targetDate > now else { return "Abgelaufen" }
        
        let components = Calendar.current.dateComponents([.day, .hour, .minute], from: now, to: targetDate)
        
        var parts: [String] = []
        if let day = components.day, day > 0 {
            parts.append("\(day) " + (day == 1 ? "Tag" : "Tage"))
        }
        
        if let hour = components.hour, hour > 0 {
            parts.append("\(hour) " + (hour == 1 ? "Stunde" : "Stunden"))
        }
        
        if let minute = components.minute, minute > 0 {
            parts.append("\(minute) " + (minute == 1 ? "Minute" : "Minuten"))
        }
        
        return parts.joined(separator: " ")
        
    }
}
