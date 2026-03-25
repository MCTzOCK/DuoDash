//
//  HomeView.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI
import CoreData
import CloudKit
import Combine

struct SpaceNavigationStack: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject public var space: SharedSpace
    
    @State private var settingsSheetVisible = false
    @State private var renameText: String = ""
    @State private var renameEmoji: String = "❤️"
    @State private var renameJoinDate: Date = Date()
    
    @State private var isShowingShareSheet = false
    @State private var isSharing = false // Für den Lade-Spinner
    
    // Hier speichern wir den fertigen Share temporär
    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    
    var body: some View {
        TabView {
            Tab {
                DashboardView(currentSpace: space)
            } label: {
                Label("Dashboard", systemImage: "house")
            }
            Tab {
                UsView(space: space)
            } label: {
                Label("Wir", systemImage: "heart.fill")
            }
            Tab {
                OrganisationTabView(space: space)
            } label: {
                Label("Organisation", systemImage: "checklist")
            }
            Tab {
                SpaceMoreView(space: space, openSettings: showSettings)
            } label: {
                Label("Mehr", systemImage: "ellipsis")
            }
        }
        .navigationTitle(space.title ?? "DuoDash")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    showSettings()
                }) {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $settingsSheetVisible) {
            SpaceSettingsSheet(isVisible: $settingsSheetVisible, renameText: $renameText, renameEmoji: $renameEmoji, joinDate: $renameJoinDate, space: space, onSave: saveRename)
        }
        .sheet(isPresented: $isShowingShareSheet) {
            if let share = activeShare, let container = activeContainer {
                CloudSharingView(share: share, container: container)
            }
        }
        .onReceive(Timer.publish(every: 15, on: .main, in: .common).autoconnect()) { _ in
            // Erzwingt einen frischen Fetch
            CoreDataManager.shared.container.viewContext.refreshAllObjects()
        }
    }
    
    private func showSettings() {
        renameText = space.title ?? "DuoDash"
        renameEmoji = space.emoji ?? "❤️"
        renameJoinDate = space.joinDate ?? Date()
        settingsSheetVisible = true
    }
    
    private func saveRename() {
        
        space.title = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        space.emoji = renameEmoji
        space.joinDate = renameJoinDate
        
        do {
            CoreDataManager.shared.save()
        } catch {
            print("Fehler: \(error.localizedDescription)")
            viewContext.rollback()
        }
        settingsSheetVisible = false
    }
    
    
    // Die neue Logik für den Button
    private func startSharingProcess() {
        isSharing = true
        
        CoreDataManager.shared.createShare(for: space) { share, container, error in
            isSharing = false
            
            if let error = error {
                print("❌ Sharing im UI fehlgeschlagen: \(error.localizedDescription)")
                // Hier könntest du später einen Alert für den User einbauen
                return
            }
            
            if let share = share, let container = container {
                self.activeShare = share
                self.activeContainer = container
                self.isShowingShareSheet = true // Jetzt das Sheet öffnen!
            }
        }
    }
}
