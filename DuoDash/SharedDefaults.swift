//
//  SharedDefaults.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//
import Foundation

// MARK: - Hilfsobjekte (Codable für JSON-Speicherung)

struct SpaceInfo: Codable, Hashable, Identifiable {
    let id: String
    let title: String
    let joinDate: Date
}

struct NoteInfo: Codable {
    let message: String
    let date: Date
    let authorID: String
}

// MARK: - Shared Defaults

struct SharedDefaults {
    
    static let suiteName = "group.com.bensiebert.DuoDash"
    
    static var store: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }
    
    // Keys
    private static let spacesKey = "widget_available_spaces"
    private static let notesPrefix = "widget_notes_"
    private static let myUserIDKey = "currentCloudKitUserID"
    
    // MARK: - Eigene User-ID
    
    static func saveMyUserID(_ id: String) {
        store.set(id, forKey: myUserIDKey)
    }
    
    static var myUserID: String {
        store.string(forKey: myUserIDKey) ?? ""
    }
    
    // MARK: - Spaces verwalten
    
    static func saveAvailableSpaces(_ spaces: [SpaceInfo]) {
        if let data = try? JSONEncoder().encode(spaces) {
            store.set(data, forKey: spacesKey)
        }
    }
    
    static var availableSpaces: [SpaceInfo] {
        guard let data = store.data(forKey: spacesKey),
              let spaces = try? JSONDecoder().decode([SpaceInfo].self, from: data) else {
            return []
        }
        return spaces
    }
    
    // MARK: - Notes pro Space
    
    static func saveNotes(_ notes: [NoteInfo], forSpaceID spaceID: String) {
        if let data = try? JSONEncoder().encode(notes) {
            store.set(data, forKey: notesPrefix + spaceID)
        }
    }
    
    static func notes(forSpaceID spaceID: String) -> [NoteInfo] {
        guard let data = store.data(forKey: notesPrefix + spaceID),
              let notes = try? JSONDecoder().decode([NoteInfo].self, from: data) else {
            return []
        }
        return notes
    }
}
