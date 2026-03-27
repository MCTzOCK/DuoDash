//
//  TogetherStatsCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//
import SwiftUI


struct TogetherStatsCard: View {
    @ObservedObject var space: SharedSpace
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            let components = Calendar.current.dateComponents(
                [.year, .month, .day, .hour, .minute, .second],
                from: space.joinDate ?? Date(),
                to: context.date
            )
            
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Zusammen seit")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(formattedJoinDate)
                            .font(.caption)
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                    }
                    
                    Spacer()
                    
                    Text("❤️")
                        .font(.title)
                }
                
                // Große Zeitanzeige
                HStack(spacing: 20) {
                    if let y = components.year, y > 0 {
                        TimeUnit(value: y, label: "Jahre")
                    }
                    if let m = components.month, m > 0 {
                        TimeUnit(value: m, label: "Monate")
                    }
                    TimeUnit(value: components.day ?? 0, label: "Tage")
                }
                
                // Live-Uhr
                Text(String(format: "%02d : %02d : %02d",
                            components.hour ?? 0,
                            components.minute ?? 0,
                            components.second ?? 0))
                    .font(.system(.title3, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                
                // Statistik-Leiste
                Divider()
                
                HStack(spacing: 0) {
                    let totalDays = Calendar.current.dateComponents([.day], from: space.joinDate ?? Date(), to: context.date).day ?? 0
                    
                    MiniStat(
                        value: formatNumber(totalDays),
                        label: "Tage"
                    )
                    
                    Divider().frame(height: 30)
                    
                    MiniStat(
                        value: formatNumber(totalDays * 24 + (components.hour ?? 0)),
                        label: "Stunden"
                    )
                    
                    Divider().frame(height: 30)
                    
                    MiniStat(
                        value: formatNumber(Int(context.date.timeIntervalSince(space.joinDate ?? Date()) / 60)),
                        label: "Minuten"
                    )
                }
            }
            .padding(20)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
    
    private var formattedJoinDate: String {
        guard let date = space.joinDate else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
    
    private func formatNumber(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = "."
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

struct TimeUnit: View {
    let value: Int
    let label: String
    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(.largeTitle, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 60)
    }
}

struct MiniStat: View {
    let value: String
    let label: String
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.caption, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
