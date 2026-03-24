//
//  CoreDataManager.swift
//  DuoDash
//
//  Created by Ben Siebert on 21.03.26.
//

import CoreData
import CloudKit
import Combine
import UIKit

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
        //privateStore.configuration = "Default" // Wenn du in Xcode keine eigenen Configs angelegt hast, ist "Default" richtig
        privateStore.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
        privateStore.cloudKitContainerOptions?.databaseScope = .private
        
        // -- Konfiguration B: Der Shared Store (Für CloudKit Sharing zwingend nötig) --
        let sharedStoreURL = storeURL.deletingLastPathComponent().appendingPathComponent("shared.sqlite")
        let sharedStore = NSPersistentStoreDescription(url: sharedStoreURL)
        //sharedStore.configuration = "Default" // Gleiches Schema für den Shared Store
        let sharedOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: containerIdentifier)
        sharedOptions.databaseScope = .shared
        sharedStore.cloudKitContainerOptions = sharedOptions
        
        // Dem Container beide Store-Beschreibungen zuweisen
        container.persistentStoreDescriptions = [privateStore, sharedStore]
        
        // 5. Stores laden
        container.loadPersistentStores { (storeDescription, error) in
            
            storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
            if let error = error as NSError? {
                // In einer echten Prod-App würdest du hier Crashlytics nutzen, statt fatalError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        // 6. Magische Einstellungen, damit UI-Updates automatisch passieren, wenn neue Daten aus der Cloud kommen
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    func createSharedSpace(title: String, emoji: String) {
        let context = container.viewContext
        
        let newSpace = SharedSpace(context: context)
        newSpace.id = UUID()
        newSpace.joinDate = Date()
        newSpace.title = title
        newSpace.emoji = emoji
        
        do {
            try context.save()
            print("🎉 Neuer SharedSpace wurde manuell erstellt!")
        } catch {
            print("❌ Fehler beim Erstellen des SharedSpace: \(error.localizedDescription)")
        }
    }
    
    // Erstellt den Share aktiv und gibt ihn über einen Callback (Completion Handler) zurück
    func createShare(for space: SharedSpace, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) {
        print("⏳ Starte manuelle Share-Erstellung...")
        
        do {
            // 1. Wir sagen Core Data: "Erstelle ein Share-Objekt für diesen Bereich"
            try container.share([space], to: nil) { objectIDs, share, cloudKitContainer, error in
                
                if let error = error {
                    print("🔥 FEHLER bei container.share: \(error.localizedDescription)")
                    DispatchQueue.main.async { completion(nil, nil, error) }
                    return
                }
                
                if let share = share {
                    print("✅ Share-Objekt im Speicher erstellt. Titel wird gesetzt...")
                    share[CKShare.SystemFieldKey.title] = "DuoDash Bereich" as CKRecordValue?
                    share[CKShare.SystemFieldKey.thumbnailImageData] = UIImage(systemName: "person.2.fill")?.jpegData(compressionQuality: 1) as CKRecordValue?
                    share[CKShare.SystemFieldKey.shareType] = "com.bensiebert.duodash.sharedspace" as CKRecordValue?
                    //share.publicPermission = .readWrite
                    
                    // 2. WICHTIG: Wir erzwingen jetzt das Speichern des Core Data Contexts!
                    // Nur so weiß das System, dass es das neue Share-Objekt auch wirklich in die Cloud hochladen muss.
                    let context = self.container.viewContext
                    context.perform {
                        do {
                            if context.hasChanges {
                                try context.save()
                                print("💾 Core Data Context gespeichert. Share wird an Apple übergeben...")
                            }
                            DispatchQueue.main.async { completion(share, cloudKitContainer, nil) }
                        } catch {
                            print("🔥 FEHLER beim Speichern des Contexts: \(error.localizedDescription)")
                            DispatchQueue.main.async { completion(nil, nil, error) }
                        }
                    }
                }
            }
        } catch {
            print("🔥 DO-CATCH FEHLER: \(error.localizedDescription)")
            DispatchQueue.main.async { completion(nil, nil, error) }
        }
    }
    
    
    func acceptShare(metadata: CKShare.Metadata) {
        // 1. Finde den "Shared Store", den wir ganz am Anfang definiert haben
        guard let sharedStore = container.persistentStoreCoordinator.persistentStores.first(where: { $0.url?.lastPathComponent == "shared.sqlite" }) else {
            print("❌ Konnte den Shared Store nicht finden!")
            return
        }
        
        // 2. Sag Core Data: "Hier ist das Ticket, lade die fremden Daten in meinen Shared Store herunter!"
        container.acceptShareInvitations(from: [metadata], into: sharedStore) { metadatas, error in
            if let error = error {
                print("🔥 Fehler beim Akzeptieren des Shares: \(error.localizedDescription)")
            } else {
                print("✅ Share erfolgreich akzeptiert und Daten werden im Hintergrund geladen!")
            }
        }
    }
    
    
}
