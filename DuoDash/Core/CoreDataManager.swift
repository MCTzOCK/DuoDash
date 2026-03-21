//
//  CoreDataManager.swift
//  DuoDash
//
//  Created by Ben Siebert on 21.03.26.
//

import CoreData
import CloudKit
import Combine

class CoreDataManager: ObservableObject {
    // 1. Singleton-Instanz für einfachen Zugriff überall in der App
    static let shared = CoreDataManager()
    
    // 2. Der magische CloudKit Container
    let container: NSPersistentCloudKitContainer
    
    // 3. Initialisierung
    private init() {
        // ACHTUNG: Der String hier MUSS exakt so heißen wie deine .xcdatamodeld Datei (ohne Dateiendung)
        container = NSPersistentCloudKitContainer(name: "DuoDash")
        
        // 4. CloudKit Sharing aktivieren (Der Container muss wissen, dass es einen Shared Store geben kann)
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Konnte Store Description nicht finden.")
        }
        
        // WICHTIG: Setze hier die Container-ID ein, die du in Schritt 1 angelegt hast!
        let containerIdentifier = "iCloud.com.bensiebert.DuoDash"
        
        // Lokale URL für den privaten Store definieren
        let storeURL = description.url!
        
        // -- Konfiguration A: Der Private Store --
        let privateStore = NSPersistentStoreDescription(url: storeURL)
        privateStore.configuration = "Default" // Wenn du in Xcode keine eigenen Configs angelegt hast, ist "Default" richtig
        privateStore.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
        privateStore.cloudKitContainerOptions?.databaseScope = .private
        
        // -- Konfiguration B: Der Shared Store (Für CloudKit Sharing zwingend nötig) --
        let sharedStoreURL = storeURL.deletingLastPathComponent().appendingPathComponent("shared.sqlite")
        let sharedStore = NSPersistentStoreDescription(url: sharedStoreURL)
        sharedStore.configuration = "Default" // Gleiches Schema für den Shared Store
        let sharedOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
        sharedOptions.databaseScope = .shared
        sharedStore.cloudKitContainerOptions = sharedOptions
        
        // Dem Container beide Store-Beschreibungen zuweisen
        container.persistentStoreDescriptions = [privateStore, sharedStore]
        
        // 5. Stores laden
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // In einer echten Prod-App würdest du hier Crashlytics nutzen, statt fatalError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // 6. Magische Einstellungen, damit UI-Updates automatisch passieren, wenn neue Daten aus der Cloud kommen
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func createSharedSpace() {
            let context = container.viewContext
            
            let newSpace = SharedSpace(context: context)
            newSpace.id = UUID()
            newSpace.joinDate = Date()
            
            do {
                try context.save()
                print("🎉 Neuer SharedSpace wurde manuell erstellt!")
            } catch {
                print("❌ Fehler beim Erstellen des SharedSpace: \(error.localizedDescription)")
            }
        }
}
