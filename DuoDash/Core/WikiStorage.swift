//
//  WikiStorage.swift
//  DuoDash
//
//  Created by Ben Siebert on 27.03.26.
//


import Foundation
import SwiftUI
import Combine

@MainActor
class WikiStorage: ObservableObject {
    @Published var entries: [WikiEntry] = []
    
    private let userID: String
    
    init(userID: String) {
        self.userID = userID
        loadEntries()
    }
    
    // MARK: - Dateipfad (komplett lokal, pro User)
    private var fileURL: URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsPath.appendingPathComponent("wiki_\(userID).json")
    }
    
    // MARK: - Laden
    func loadEntries() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            entries = []
            return
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            entries = try JSONDecoder().decode([WikiEntry].self, from: data)
        } catch {
            print("❌ Wiki laden fehlgeschlagen: \(error)")
            entries = []
        }
    }
    
    // MARK: - Speichern
    func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL)
        } catch {
            print("❌ Wiki speichern fehlgeschlagen: \(error)")
        }
    }
    
    // MARK: - CRUD Operationen
    func addEntry(_ entry: WikiEntry) {
        entries.insert(entry, at: 0)
        save()
    }
    
    func updateEntry(_ entry: WikiEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            var updated = entry
            updated.updatedAt = Date()
            entries[index] = updated
            save()
        }
    }
    
    func deleteEntry(_ entry: WikiEntry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }
    
    // MARK: - Gefilterte Abfragen
    func entries(for category: WikiCategory) -> [WikiEntry] {
        entries.filter { $0.category == category }
    }
}
