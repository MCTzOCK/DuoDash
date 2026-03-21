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
        Group {
            if spaces.isEmpty {
                // Nutzer hat noch keinen Bereich -> Onboarding
                OnboardingView()
            } else {
                // Nutzer hat einen Bereich (selbst erstellt oder per Link beigetreten)
                DashboardView(currentSpace: spaces.first!)
            }
        }
    }
}

