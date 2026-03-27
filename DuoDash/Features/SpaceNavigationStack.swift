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


fileprivate let MIT_LICENSE = """
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
    """



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
                UAUICommonInfoView(title: "DuoDash", logoName: "Logo", version: "1.0", libraries: [
                    OpenSourceLibrary(name: "SwiftEmojiPicker", copyright: "Copyright (c) 2026 Sergey Likhanov", licenseText: MIT_LICENSE)
                ], content: {
                    Section("Trinkgeld") {
                        NavigationLink(destination: TipJarView()) {
                            SettingsInfoRow(icon: "cup.and.heat.waves.fill", color: .accent, title: "Trinkgeld", value: "no-disclosure")
                        }
                        .buttonStyle(.plain)
                    }
                })
            } label: {
                Label("Mehr", systemImage: "ellipsis.circle")
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
