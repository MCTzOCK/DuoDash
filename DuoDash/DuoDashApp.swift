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
    
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
            // Hier injizieren wir den viewContext in die SwiftUI-Umgebung
                .environment(\.managedObjectContext, coreDataManager.container.viewContext)
                .onAppear {
                    coreDataManager.fetchAndStoreCurrentUserID()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        coreDataManager.syncDataToWidget()
                    }
                }
        }
    }
}
