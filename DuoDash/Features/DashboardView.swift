//
//  DashboardView.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//


import SwiftUI
import CloudKit

struct DashboardView: View {
    @ObservedObject var currentSpace: SharedSpace
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var isShowingShareSheet = false
    @State private var isSharing = false
    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // MARK: 1. Together Stats (Kompakt)
                    OLD__TogetherStatsCard(space: currentSpace)
                    
                    // MARK: 2. Nächster Countdown
                    NextCountdownCard(space: currentSpace)
                    
                    // MARK: 3. Love Note vom Partner
                    LatestLoveNoteCard(space: currentSpace)
                    
                    // MARK: 4. Zwei-Spalten Grid (Listen + Events)
                    HStack(spacing: 14) {
                        ListsSummaryCard(space: currentSpace)
                        UpcomingEventCard(space: currentSpace)
                    }
                    .padding(.horizontal)
                    
                    // MARK: 5. Letzte Erinnerung
                    LatestMemoryCard(space: currentSpace)
                    
                    // MARK: 6. Date-Ideen Vorschlag
                    RandomDateIdeaCard(space: currentSpace)
                    
                    // MARK: 7. Quick Actions
                    QuickActionsCard(
                        space: currentSpace,
                        isSharing: $isSharing,
                        onShare: { startSharingProcess() }
                    )
                    
                    Spacer(minLength: 30)
                }
                .padding(.top, 10)
            }
            .navigationTitle("Dashboard")
            .background(Color(UIColor.systemGroupedBackground))
            .sheet(isPresented: $isShowingShareSheet) {
                if let share = activeShare, let container = activeContainer {
                    CloudSharingView(share: share, container: container)
                }
            }
        }
    }
    
    private func startSharingProcess() {
        isSharing = true
        CoreDataManager.shared.createShare(for: currentSpace) { share, container, error in
            isSharing = false
            if let error = error {
                print("❌ Sharing fehlgeschlagen: \(error.localizedDescription)")
                return
            }
            if let share = share, let container = container {
                self.activeShare = share
                self.activeContainer = container
                self.isShowingShareSheet = true
            }
        }
    }
}
