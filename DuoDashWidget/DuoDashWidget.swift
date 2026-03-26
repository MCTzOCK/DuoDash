//
//  DuoDashWidget.swift
//  DuoDashWidget
//
//  Created by Ben Siebert on 26.03.26.
//
import WidgetKit
import SwiftUI

// MARK: - ===========================================
// MARK: - TIMELINE PROVIDER
// MARK: - ===========================================

struct LoveNoteTimelineProvider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> LoveNoteEntry {
        LoveNoteEntry(
            date: Date(),
            notes: [NoteInfo(message: "Ich liebe dich! 💕", date: Date(), authorID: "")],
            theme: .romantic,
            spaceName: "DuoDash"
        )
    }
    
    func snapshot(for configuration: LoveNoteWidgetIntent, in context: Context) async -> LoveNoteEntry {
        getEntry(for: configuration)
    }
    
    func timeline(for configuration: LoveNoteWidgetIntent, in context: Context) async -> Timeline<LoveNoteEntry> {
        let entry = getEntry(for: configuration)
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
    
    private func getEntry(for configuration: LoveNoteWidgetIntent) -> LoveNoteEntry {
        let spaceID = configuration.space?.id ?? SharedDefaults.availableSpaces.first?.id ?? ""
        let spaceName = configuration.space?.title ?? SharedDefaults.availableSpaces.first?.title ?? "DuoDash"
        let notes = SharedDefaults.notes(forSpaceID: spaceID)
        let theme = configuration.theme
        
        return LoveNoteEntry(
            date: Date(),
            notes: notes.isEmpty ? [NoteInfo(message: "Noch keine Nachricht 💕", date: Date(), authorID: "")] : notes,
            theme: theme,
            spaceName: spaceName
        )
    }
}

// MARK: - Timeline Entry

struct LoveNoteEntry: TimelineEntry {
    let date: Date
    let notes: [NoteInfo]
    let theme: WidgetTheme
    let spaceName: String
}

// MARK: - ===========================================
// MARK: - WIDGET VIEWS (Alle Größen)
// MARK: - ===========================================

struct LoveNoteWidgetView: View {
    var entry: LoveNoteEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget

struct SmallWidgetView: View {
    let entry: LoveNoteEntry
    private var theme: WidgetTheme { entry.theme }
    private var note: NoteInfo { entry.notes.first ?? NoteInfo(message: "💕", date: Date(), authorID: "") }
    
    var body: some View {
        ZStack {
            // Hintergrund
            LinearGradient(colors: theme.backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VStack(alignment: .leading, spacing: 6) {
                // Header
                HStack(spacing: 4) {
                    Image(systemName: theme.icon)
                        .font(.caption2)
                        .foregroundColor(theme.accentColor)
                    Text("Love Note")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(theme.accentColor)
                    Spacer()
                    if !theme.decorativeEmoji.isEmpty {
                        Text(theme.decorativeEmoji)
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                // Nachricht
                Text(note.message)
                    .font(.system(.footnote, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(theme.textColor)
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Datum
                Text(relativeDate(note.date))
                    .font(.system(size: 9, design: .rounded))
                    .foregroundColor(theme.secondaryTextColor)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(14)
        }
    }
    
    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Medium Widget

struct MediumWidgetView: View {
    let entry: LoveNoteEntry
    private var theme: WidgetTheme { entry.theme }
    private var note: NoteInfo { entry.notes.first ?? NoteInfo(message: "💕", date: Date(), authorID: "") }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: theme.backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            
            HStack(spacing: 16) {
                // Linke Seite: Dekoratives Element
                VStack {
                    Spacer()
                    Image(systemName: theme.icon)
                        .font(.system(size: 36))
                        .foregroundColor(theme.accentColor.opacity(0.3))
                    Spacer()
                }
                .frame(width: 60)
                
                // Rechte Seite: Inhalt
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Love Note")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundColor(theme.accentColor)
                        
                        if !theme.decorativeEmoji.isEmpty {
                            Text(theme.decorativeEmoji)
                                .font(.caption)
                        }
                        Spacer()
                    }
                    
                    Spacer()
                    
                    Text("\"\(note.message)\"")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(theme.textColor)
                        .lineLimit(3)
                        .italic()
                    
                    Spacer()
                    
                    Text(relativeDate(note.date))
                        .font(.system(size: 10, design: .rounded))
                        .foregroundColor(theme.secondaryTextColor)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(16)
        }
    }
    
    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Large Widget (Zeigt die letzten 3 Notes!)

struct LargeWidgetView: View {
    let entry: LoveNoteEntry
    private var theme: WidgetTheme { entry.theme }
    
    private var displayNotes: [NoteInfo] {
        Array(entry.notes.prefix(3))
    }
    
    var body: some View {
        ZStack {
            LinearGradient(colors: theme.backgroundColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    Image(systemName: theme.icon)
                        .font(.title3)
                        .foregroundColor(theme.accentColor)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Love Notes")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(theme.textColor)
                        Text(entry.spaceName)
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    
                    Spacer()
                    
                    if !theme.decorativeEmoji.isEmpty {
                        Text(theme.decorativeEmoji)
                            .font(.title3)
                    }
                }
                
                Divider()
                    .background(theme.accentColor.opacity(0.3))
                
                // Die letzten 3 Notes
                ForEach(Array(displayNotes.enumerated()), id: \.offset) { index, note in
                    LargeWidgetNoteRow(note: note, theme: theme, isLatest: index == 0)
                    
                    if index < displayNotes.count - 1 {
                        Divider()
                            .background(theme.accentColor.opacity(0.15))
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding(16)
        }
    }
}

struct LargeWidgetNoteRow: View {
    let note: NoteInfo
    let theme: WidgetTheme
    let isLatest: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Datum-Badge
            HStack(spacing: 4) {
                if isLatest {
                    Text("NEU")
                        .font(.system(size: 8, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(theme.accentColor)
                        .clipShape(Capsule())
                }
                
                Text(formattedDate(note.date))
                    .font(.system(size: 10, design: .rounded))
                    .foregroundColor(theme.secondaryTextColor)
                
                Spacer()
            }
            
            // Nachricht
            Text(note.message)
                .font(.system(isLatest ? .subheadline : .footnote, design: .rounded))
                .fontWeight(isLatest ? .semibold : .regular)
                .foregroundColor(isLatest ? theme.textColor : theme.secondaryTextColor)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - ===========================================
// MARK: - WIDGET KONFIGURATION
// MARK: - ===========================================

struct DuoDashLoveNoteWidget: Widget {
    let kind: String = "DuoDashLoveNoteWidget"
    
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: LoveNoteWidgetIntent.self,
            provider: LoveNoteTimelineProvider()
        ) { entry in
            LoveNoteWidgetView(entry: entry)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: entry.theme.backgroundColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("Love Note")
        .description("Zeigt Nachrichten deines Partners auf dem Homescreen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Previews

#Preview("Small - Romantisch", as: .systemSmall) {
    DuoDashLoveNoteWidget()
} timeline: {
    LoveNoteEntry(date: Date(), notes: [NoteInfo(message: "Du bist mein Lieblingsmensch! 🥰", date: Date(), authorID: "")], theme: .romantic, spaceName: "Unser Space")
}

#Preview("Medium - Nachthimmel", as: .systemMedium) {
    DuoDashLoveNoteWidget()
} timeline: {
    LoveNoteEntry(date: Date(), notes: [NoteInfo(message: "Ich kann es kaum erwarten, dich heute Abend zu sehen!", date: Date(), authorID: "")], theme: .night, spaceName: "Unser Space")
}

#Preview("Large - Garten", as: .systemLarge) {
    DuoDashLoveNoteWidget()
} timeline: {
    LoveNoteEntry(
        date: Date(),
        notes: [
            NoteInfo(message: "Vergiss nicht: Ich liebe dich unendlich! 💕", date: Date(), authorID: ""),
            NoteInfo(message: "Viel Erfolg beim Meeting heute! Du schaffst das 💪", date: Date().addingTimeInterval(-3600), authorID: ""),
            NoteInfo(message: "Danke für das tolle Frühstück heute Morgen 🥐", date: Date().addingTimeInterval(-86400), authorID: ""),
        ],
        theme: .garden,
        spaceName: "Ben & Anna"
    )
}
