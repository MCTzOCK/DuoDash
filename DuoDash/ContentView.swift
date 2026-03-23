//
//  ContentView.swift
//  DuoDash
//
//  Created by Ben Siebert on 21.03.26.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SharedSpace.joinDate, ascending: true)],
        animation: .default)
    private var spaces: FetchedResults<SharedSpace>
    
    var body: some View {
        NavigationStack {
            if spaces.isEmpty {
                OnboardingView()
            } else {
                List {
                    ForEach(spaces) { space in
                        NavigationLink(destination: DashboardView(currentSpace: space)) {
                            Text(space.id != nil ? String(describing: space.id) : "Unbenannter Bereich")
                                .font(.headline)
                        }
                    }
                }
                .navigationTitle("Deine Bereiche")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: {
                            CoreDataManager.shared.createSharedSpace()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
    }
}

