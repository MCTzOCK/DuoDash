//
//  ContentView.swift
//  DuoDash
//
//  Created by Ben Siebert on 21.03.26.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SharedSpace.joinDate, ascending: true)],
        animation: .default)
    private var spaces: FetchedResults<SharedSpace>
    @ObservedObject var coreData = CoreDataManager.shared
    
    var body: some View {
        NavigationStack {
            if spaces.isEmpty {
                OnboardingView()
            } else {
                OverviewView()
            }
        }
        .onChange(of: coreData.lastSyncUpdate) { _ in
            // Zwingt ALLE FetchRequests in diesem View, ihre Daten neu zu laden
            viewContext.refreshAllObjects()
        }

    }
}

