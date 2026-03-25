//
//  ListsOverviewView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI
import CoreData
import PhotosUI

struct ListsOverviewView: View {
    
    @ObservedObject var space: SharedSpace
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var coreData = CoreDataManager.shared
    
    @FetchRequest var containers: FetchedResults<ListContainer>
    
    @State private var showingCreateSheet = false
    
    init(space: SharedSpace) {
        self.space = space
        _containers = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \ListContainer.title, ascending: true)],
            predicate: NSPredicate(format: "space == %@", space)
        )
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                if containers.isEmpty {
                    // MARK: Empty State
                    VStack(spacing: 12) {
                        Image(systemName: "checklist")
                            .font(.system(size: 50))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                        
                        Text("Noch keine Listen")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Erstellt gemeinsame Einkaufslisten, To-Do's, Packlisten und mehr.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button {
                            showingCreateSheet = true
                        } label: {
                            Label("Liste erstellen", systemImage: "plus")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            // Color.accentColor ist die sichere native Variante
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 60)
                    
                } else {
                    // MARK: Listen-Grid (2 Spalten wie Apple Reminders)
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(containers) { container in
                            NavigationLink(destination: ListDetailView(container: container, space: space)) {
                                ListContainerCard(container: container)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Listen")
        .background(Color(UIColor.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateListView(space: space)
        }
        .id(coreData.lastSyncUpdate)
        .onChange(of: coreData.lastSyncUpdate) { _ in
            // Zwingt ALLE FetchRequests in diesem View, ihre Daten neu zu laden
            viewContext.refreshAllObjects()
        }
    }
}
