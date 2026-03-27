//
//  NextCountdownCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//
import SwiftUI


struct NextCountdownCard: View {
    @ObservedObject var space: SharedSpace
    
    private var nextCountdown: Countdown? {
        let all = (space.countdowns?.allObjects as? [Countdown]) ?? []
        return all
            .filter { ($0.targetDate ?? .distantPast) > Date() }
            .sorted { ($0.targetDate ?? .distantFuture) < ($1.targetDate ?? .distantFuture) }
            .first
    }
    
    var body: some View {
        if let countdown = nextCountdown {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.accent)
                        .font(.headline)
                    Text("Nächster Countdown")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(countdown.title ?? "Countdown")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        let days = Calendar.current.dateComponents([.day], from: Date(), to: countdown.targetDate ?? Date()).day ?? 0
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(days)")
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.accent)
                            Text(days == 1 ? "Tag" : "Tage")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Text(formattedDate(countdown.targetDate ?? Date()))
                            .font(.caption)
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    
                    Spacer()
                    
                    // Bild oder Deko
                    if let imgData = countdown.imageData, let uiImage = UIImage(data: imgData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        Image(systemName: "hourglass")
                            .font(.system(size: 30))
                            .foregroundColor(.blue.opacity(0.3))
                            .frame(width: 70, height: 70)
                            .background(Color.accent.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(20)
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
