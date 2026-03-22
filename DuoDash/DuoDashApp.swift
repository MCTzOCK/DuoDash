//
//  DuoDashApp.swift
//  DuoDash
//
//  Created by Ben Siebert on 21.03.26.
//

import SwiftUI
import CoreData

@main
struct DuoDashApp: App {
    // Wir initialisieren unseren CoreDataManager als StateObject, damit er am Leben bleibt
    @StateObject private var coreDataManager = CoreDataManager.shared
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            // Hier injizieren wir den viewContext in die SwiftUI-Umgebung
                .environment(\.managedObjectContext, coreDataManager.container.viewContext)
        }
    }
}
