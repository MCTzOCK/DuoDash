//
//  DashboardView.swift
//  DuoDash
//
//  Created by Ben Siebert on 21.03.26.
//
import SwiftUI
import CloudKit

struct OLD__DashboardView: View {
    @ObservedObject var currentSpace: SharedSpace
    
    @State private var isShowingShareSheet = false
    @State private var isSharing = false // Für den Lade-Spinner
    
    // Hier speichern wir den fertigen Share temporär
    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    OLD__TogetherStatsCard(space: currentSpace)
                }
            }
            .navigationTitle("Dashboard")
            // Das Sheet öffnet sich nur, wenn activeShare und activeContainer nicht nil sind
            .sheet(isPresented: $isShowingShareSheet) {
                if let share = activeShare, let container = activeContainer {
                    CloudSharingView(share: share, container: container)
                }
            }
        }
    }
    
    // Die neue Logik für den Button
    private func startSharingProcess() {
        isSharing = true
        
        CoreDataManager.shared.createShare(for: currentSpace) { share, container, error in
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
