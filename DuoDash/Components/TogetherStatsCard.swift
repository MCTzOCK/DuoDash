//
//  TogetherStatsCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI

struct TogetherStatsCard: View {
    
    @ObservedObject var space: SharedSpace
    
    let cardColor = Color(red: 0.95, green: 0.95, blue: 0.97) // Helles Grau
    let accentColor = Color.accent
    
    
    var body: some View {
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            timelineContent(currentDate: context.date)
        }
        
    }
    
    @ViewBuilder
    func timelineContent(currentDate: Date) -> some View {
        VStack(spacing: 0) {
            
            // --- KOPFZEILE ---
            Text("❤️ Zusammen seit")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 20)
            
            Divider().padding(.vertical, 10)
            
            // --- TEIL 1: KOMBINIERTE ANZEIGE ---
            VStack(spacing: 5) {
                let components = getCombinedComponents(now: currentDate)
                
                Text(formatCombined(components))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                    .monospacedDigit()
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 20)
            
            // --- TRENNER ---
            HStack {
                Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
                Text("STATISTIK")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
            }
            .padding(.horizontal)
            .padding(.bottom, 15)
            
            // --- TEIL 2: EINZEL-STATS MIT "ODER" ---
            VStack(spacing: 8) {
                // Wir berechnen die Einzelwerte relativ zu 'context.date' (jetzt)
                
                SingleStatRow(
                    value: Int(currentDate.timeIntervalSince(space.joinDate ?? Date())),
                    unit: "Sekunden"
                )
                
                OrSeparator()
                
                SingleStatRow(
                    value: Int(currentDate.timeIntervalSince(space.joinDate ?? Date()) / 60),
                    unit: "Minuten"
                )
                
                OrSeparator()
                
                SingleStatRow(
                    value: Int(currentDate.timeIntervalSince(space.joinDate ?? Date()) / 3600),
                    unit: "Stunden"
                )
                
                OrSeparator()
                
                SingleStatRow(
                    value: Calendar.current.dateComponents([.day], from: space.joinDate ?? Date(), to: currentDate).day ?? 0,
                    unit: "Tage"
                )
            }
            .padding(.bottom, 20)
        }
        .background(cardColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding()
    }
    
    func getCombinedComponents(now: Date) -> DateComponents {
        return Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: space.joinDate ?? Date(),
            to: now
        )
    }
    
    func formatCombined(_ c: DateComponents) -> String {
        var parts: [String] = []
        if let y = c.year, y > 0 { parts.append("\(y) J") }
        if let m = c.month, m > 0 { parts.append("\(m) M") }
        if let d = c.day, d > 0 { parts.append("\(d) T") }
        
        let timeString = String(format: "%02d Std : %02d Min : %02d Sek", c.hour ?? 0, c.minute ?? 0, c.second ?? 0)
        
        if parts.isEmpty {
            return timeString
        } else {
            return parts.joined(separator: ", ") + "\n" + timeString
        }
    }

}


struct SingleStatRow: View {
    let value: Int
    let unit: String
    
    // Formatter für Tausendertrennzeichen (z.B. 1.000.000)
    var numberFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = "."
        return f
    }
    
    var body: some View {
        HStack {
            Text(numberFormatter.string(from: NSNumber(value: value)) ?? "\(value)")
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
            
            Text(unit)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

struct OrSeparator: View {
    var body: some View {
        Text("- oder -")
            .font(.caption2)
            .foregroundColor(Color.gray.opacity(0.5))
            .padding(.vertical, 2)
    }
}
