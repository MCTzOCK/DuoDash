//
//  WidgetIntents.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//

import AppIntents
import SwiftUI

// MARK: - ===========================================
// MARK: - WIDGET THEMES (Die verschiedenen Designs!)
// MARK: - ===========================================

enum WidgetTheme: String, AppEnum {
    case romantic = "Romantisch"
    case minimal = "Minimal"
    case sunset = "Sonnenuntergang"
    case ocean = "Ozean"
    case night = "Nachthimmel"
    case garden = "Garten"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Widget-Design")
    
    static var caseDisplayRepresentations: [WidgetTheme: DisplayRepresentation] = [
        .romantic: "💕 Romantisch",
        .minimal: "🤍 Minimal",
        .sunset: "🌅 Sonnenuntergang",
        .ocean: "🌊 Ozean",
        .night: "🌙 Nachthimmel",
        .garden: "🌸 Garten",
    ]
    
    // Hintergrund-Gradient
    var backgroundColors: [Color] {
        switch self {
        case .romantic: return [Color(red: 1.0, green: 0.85, blue: 0.88), Color(red: 1.0, green: 0.7, blue: 0.78)]
        case .minimal: return [Color(red: 0.97, green: 0.97, blue: 0.98), Color(red: 0.93, green: 0.93, blue: 0.95)]
        case .sunset: return [Color(red: 1.0, green: 0.8, blue: 0.6), Color(red: 0.9, green: 0.5, blue: 0.6)]
        case .ocean: return [Color(red: 0.7, green: 0.88, blue: 0.95), Color(red: 0.5, green: 0.75, blue: 0.9)]
        case .night: return [Color(red: 0.15, green: 0.15, blue: 0.3), Color(red: 0.08, green: 0.08, blue: 0.2)]
        case .garden: return [Color(red: 0.85, green: 0.95, blue: 0.85), Color(red: 0.7, green: 0.9, blue: 0.75)]
        }
    }
    
    var accentColor: Color {
        switch self {
        case .romantic: return Color(red: 0.9, green: 0.2, blue: 0.4)
        case .minimal: return .secondary
        case .sunset: return Color(red: 0.8, green: 0.3, blue: 0.3)
        case .ocean: return Color(red: 0.2, green: 0.5, blue: 0.7)
        case .night: return Color(red: 0.7, green: 0.7, blue: 1.0)
        case .garden: return Color(red: 0.3, green: 0.6, blue: 0.35)
        }
    }
    
    var textColor: Color {
        switch self {
        case .night: return .white
        default: return Color(red: 0.2, green: 0.2, blue: 0.25)
        }
    }
    
    var secondaryTextColor: Color {
        switch self {
        case .night: return .white.opacity(0.6)
        default: return Color(red: 0.4, green: 0.4, blue: 0.45)
        }
    }
    
    var icon: String {
        switch self {
        case .romantic: return "heart.fill"
        case .minimal: return "heart"
        case .sunset: return "sun.haze.fill"
        case .ocean: return "water.waves"
        case .night: return "moon.stars.fill"
        case .garden: return "leaf.fill"
        }
    }
    
    var decorativeEmoji: String {
        switch self {
        case .romantic: return "💕"
        case .minimal: return ""
        case .sunset: return "🧡"
        case .ocean: return "💙"
        case .night: return "✨"
        case .garden: return "🌷"
        }
    }
}

// MARK: - ===========================================
// MARK: - SPACE ENTITY (Für die Auswahl im Widget-Editor)
// MARK: - ===========================================

struct SpaceEntity: AppEntity {
    var id: String
    var title: String
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Space")
    static var defaultQuery = SpaceEntityQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title)")
    }
}

struct SpaceEntityQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [SpaceEntity] {
        SharedDefaults.availableSpaces.filter { identifiers.contains($0.id) }.map {
            SpaceEntity(id: $0.id, title: $0.title)
        }
    }
    
    func suggestedEntities() async throws -> [SpaceEntity] {
        SharedDefaults.availableSpaces.map {
            SpaceEntity(id: $0.id, title: $0.title)
        }
    }
    
    func defaultResult() async -> SpaceEntity? {
        SharedDefaults.availableSpaces.first.map {
            SpaceEntity(id: $0.id, title: $0.title)
        }
    }
}

// MARK: - ===========================================
// MARK: - WIDGET KONFIGURATION (AppIntent)
// MARK: - ===========================================

struct LoveNoteWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Love Note"
    static var description = IntentDescription("Zeigt die neueste Nachricht deines Partners.")
    
    @Parameter(title: "Space")
    var space: SpaceEntity?
    
    @Parameter(title: "Design", default: .romantic)
    var theme: WidgetTheme
}
