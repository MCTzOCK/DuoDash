//
//  WikiEntry.swift
//  DuoDash
//
//  Created by Ben Siebert on 27.03.26.
//


import Foundation

// MARK: - Entry Typen
enum WikiEntryType: String, Codable, CaseIterable, Identifiable {
    case text = "Notiz"
    case link = "Link"
    case image = "Bild"
    case size = "Größe"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .text: return "note.text"
        case .link: return "link"
        case .image: return "photo"
        case .size: return "ruler"
        }
    }
    
    var color: String {
        switch self {
        case .text: return "blue"
        case .link: return "green"
        case .image: return "purple"
        case .size: return "orange"
        }
    }
}

// MARK: - Kategorien
enum WikiCategory: String, Codable, CaseIterable, Identifiable {
    case gifts = "Geschenkideen"
    case favorites = "Lieblinge"
    case sizes = "Größen & Maße"
    case important = "Wichtiges"
    case memories = "Erinnerungen"
    case other = "Sonstiges"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .gifts: return "gift.fill"
        case .favorites: return "heart.fill"
        case .sizes: return "ruler.fill"
        case .important: return "exclamationmark.circle.fill"
        case .memories: return "sparkles"
        case .other: return "folder.fill"
        }
    }
    
    var color: String {
        switch self {
        case .gifts: return "pink"
        case .favorites: return "red"
        case .sizes: return "orange"
        case .important: return "yellow"
        case .memories: return "purple"
        case .other: return "gray"
        }
    }
}

// MARK: - Der Wiki-Eintrag
struct WikiEntry: Identifiable, Codable {
    let id: UUID
    var type: WikiEntryType
    var category: WikiCategory
    var title: String
    var content: String // Notiztext, URL, oder Größenangabe
    var imageData: Data?
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        type: WikiEntryType,
        category: WikiCategory,
        title: String,
        content: String = "",
        imageData: Data? = nil
    ) {
        self.id = id
        self.type = type
        self.category = category
        self.title = title
        self.content = content
        self.imageData = imageData
        self.createdAt = Date()
        self.updatedAt = Date()
    }
}
