//
//  TogetherWidget.swift
//  DuoDash
//
//  Created by Ben Siebert on 27.03.26.
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - AppIntent für das Together Widget
struct TogetherWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Zusammen seit..."
    static var description = IntentDescription("Zeigt an, wie lange ihr schon zusammen seid.")
    
    @Parameter(title: "Space")
    var space: SpaceEntity?
    
    @Parameter(title: "Design", default: .romantic)
    var theme: WidgetTheme
}

// MARK: - Provider
struct TogetherTimelineProvider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> TogetherEntry {
        TogetherEntry(date: Date(), joinDate: Calendar.current.date(byAdding: .year, value: -2, to: Date())!, theme: .romantic, spaceName: "DuoDash")
    }
    
    func snapshot(for configuration: TogetherWidgetIntent, in context: Context) async -> TogetherEntry {
        getEntry(for: configuration)
    }
    
    func timeline(for configuration: TogetherWidgetIntent, in context: Context) async -> Timeline<TogetherEntry> {
        let entry = getEntry(for: configuration)
        
        // Das Widget muss sich nur einmal pro Nacht (um 00:01 Uhr) aktualisieren, wenn ein neuer Tag anbricht!
        let tomorrow = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400 + 60)
        return Timeline(entries: [entry], policy: .after(tomorrow))
    }
    
    private func getEntry(for configuration: TogetherWidgetIntent) -> TogetherEntry {
        let spaceID = configuration.space?.id ?? SharedDefaults.availableSpaces.first?.id ?? ""
        
        // Finde den passenden Space aus den gespeicherten Daten, um das joinDate zu bekommen
        let selectedSpace = SharedDefaults.availableSpaces.first { $0.id == spaceID } ?? SharedDefaults.availableSpaces.first
        
        let spaceName = selectedSpace?.title ?? "DuoDash"
        let joinDate = selectedSpace?.joinDate ?? Date()
        let theme = configuration.theme
        
        return TogetherEntry(date: Date(), joinDate: joinDate, theme: theme, spaceName: spaceName)
    }
}

// MARK: - Entry
struct TogetherEntry: TimelineEntry {
    let date: Date
    let joinDate: Date
    let theme: WidgetTheme
    let spaceName: String
}

// MARK: - Widget Views
struct TogetherWidgetView: View {
    var entry: TogetherEntry
    @Environment(\.widgetFamily) var family
    
    private var theme: WidgetTheme { entry.theme }
    
    // Berechnet die exakten Jahre, Monate und Tage
    private var components: DateComponents {
        Calendar.current.dateComponents([.year, .month, .day], from: entry.joinDate, to: Date())
    }
    
    // Berechnet die absoluten Tage (z.B. "843 Tage")
    private var totalDays: Int {
        Calendar.current.dateComponents([.day], from: entry.joinDate, to: Date()).day ?? 0
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: theme.backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            
            switch family {
            case .systemSmall:
                // SMALL WIDGET
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "heart.circle.fill")
                            .font(.title2)
                            .foregroundColor(theme.accentColor)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Text("Wir Zwei")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(theme.secondaryTextColor)
                    
                    Text("\(totalDays) Tage")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(theme.textColor)
                        .minimumScaleFactor(0.5)
                }
                .padding(14)
                
            default:
                // MEDIUM & LARGE WIDGET
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "heart.circle.fill")
                            .font(.title)
                            .foregroundColor(theme.accentColor)
                        
                        Text(entry.spaceName)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(theme.textColor)
                        
                        Spacer()
                        
                        if !theme.decorativeEmoji.isEmpty {
                            Text(theme.decorativeEmoji)
                                .font(.title3)
                        }
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 20) {
                        if let y = components.year, y > 0 {
                            TimeBox(value: y, unit: y == 1 ? "Jahr" : "Jahre", theme: theme)
                        }
                        if let m = components.month, m > 0 {
                            TimeBox(value: m, unit: m == 1 ? "Monat" : "Monate", theme: theme)
                        }
                        TimeBox(value: components.day ?? 0, unit: components.day == 1 ? "Tag" : "Tage", theme: theme)
                    }
                    
                    Spacer()
                    
                    Text("Seit dem \(formattedDate(entry.joinDate))")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(theme.secondaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(16)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TimeBox: View {
    let value: Int
    let unit: String
    let theme: WidgetTheme
    
    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(theme.textColor)
            
            Text(unit)
                .font(.system(.caption2, design: .rounded))
                .fontWeight(.medium)
                .foregroundColor(theme.secondaryTextColor)
                .textCase(.uppercase)
        }
    }
}

// MARK: - Widget Konfiguration
struct DuoDashTogetherWidget: Widget {
    let kind: String = "DuoDashTogetherWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: TogetherWidgetIntent.self,
            provider: TogetherTimelineProvider()
        ) { entry in
            TogetherWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(colors: entry.theme.backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                }
        }
        .configurationDisplayName("Zusammen seit")
        .description("Zeigt auf die Sekunde, wie lange ihr ein Team seid.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
