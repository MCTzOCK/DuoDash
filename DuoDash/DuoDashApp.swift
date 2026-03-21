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
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
