//
//  MemoryOverviewView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//


import SwiftUI
import CoreData
import PhotosUI

// MARK: - ===========================================
// MARK: - 1. MEMORY ÜBERSICHT (Hauptview)
// MARK: - ===========================================

struct MemoryOverviewView: View {
    
    @ObservedObject var space: SharedSpace
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest var memories: FetchedResults<Memory>
    
    @State private var showingCreateSheet = false
    @State private var memoryToEdit: Memory? = nil
    @State private var showingSwiper = false
    @State private var searchText = ""
    
    init(space: SharedSpace) {
        self.space = space
        _memories = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Memory.date, ascending: false)],
            predicate: NSPredicate(format: "space == %@", space)
        )
    }
    
    private var filteredMemories: [Memory] {
        guard !searchText.isEmpty else { return Array(memories) }
        return memories.filter { memory in
            (memory.title?.localizedCaseInsensitiveContains(searchText) == true) ||
            (memory.bodyText?.localizedCaseInsensitiveContains(searchText) == true) ||
            (memory.location?.localizedCaseInsensitiveContains(searchText) == true)
        }
    }
    
    /// Gruppiert Memories nach Monat & Jahr
    private var groupedMemories: [(key: String, memories: [Memory])] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "LLLL yyyy"
        
        let grouped = Dictionary(grouping: filteredMemories) { memory -> String in
            guard let date = memory.date else { return "Unbekannt" }
            return formatter.string(from: date).capitalized
        }
        
        return grouped
            .map { (key: $0.key, memories: $0.value) }
            .sorted { lhs, rhs in
                guard let lhsDate = lhs.memories.first?.date,
                      let rhsDate = rhs.memories.first?.date else { return false }
                return lhsDate > rhsDate
            }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: Memory Swiper Teaser (Nur wenn Memories vorhanden)
                if memories.count >= 2 {
                    Button {
                        showingSwiper = true
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "sparkles.rectangle.stack.fill")
                                .font(.title2)
                                .foregroundColor(.purple)
                                .frame(width: 44, height: 44)
                                .background(Color.purple.opacity(0.15))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Erinnerungen durchblättern")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                Text("Swipe durch eure schönsten Momente")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                
                // MARK: Timeline
                if filteredMemories.isEmpty {
                    // Empty State
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                        
                        Text("Noch keine Erinnerungen")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Haltet eure schönsten gemeinsamen Momente hier fest.")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button {
                            showingCreateSheet = true
                        } label: {
                            Label("Erinnerung erstellen", systemImage: "plus")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.vertical, 60)
                } else {
                    // Gruppierte Memory-Karten
                    ForEach(groupedMemories, id: \.key) { group in
                        VStack(alignment: .leading, spacing: 14) {
                            // Monats-Header
                            Text(group.key)
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                            
                            ForEach(group.memories) { memory in
                                Button {
                                    memoryToEdit = memory
                                } label: {
                                    MemoryCardView(memory: memory)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                Spacer(minLength: 20)
            }
        }
        .navigationTitle("Memories")
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Erinnerungen durchsuchen")
        .sheet(isPresented: $showingCreateSheet) {
            CreateMemoryView(space: space)
        }
        .sheet(item: $memoryToEdit) { memory in
            MemoryDetailView(memory: memory, space: space)
        }
        .fullScreenCover(isPresented: $showingSwiper) {
            MemorySwiperView(memories: Array(memories))
        }
    }
}

// MARK: - ===========================================
// MARK: - 2. MEMORY KARTE (Wiederverwendbar)
// MARK: - ===========================================


// MARK: - ===========================================
// MARK: - 3. MEMORY ERSTELLEN (Sheet)
// MARK: - ===========================================


// MARK: - ===========================================
// MARK: - 4. MEMORY BEARBEITEN (Sheet)
// MARK: - ===========================================


// MARK: - ===========================================
// MARK: - 5. MEMORY SWIPER (Das Highlight-Feature!)
// MARK: - ===========================================


// MARK: - ===========================================
// MARK: - 6. SWIPER KARTE (Die große, schöne Karte)
// MARK: - ===========================================

