//
//  PartnerWikiView.swift
//  DuoDash
//
//  Created by Ben Siebert on 27.03.26.
//


import SwiftUI

struct PartnerWikiView: View {
    @StateObject private var storage: WikiStorage
    @State private var showingCreateSheet = false
    @State private var selectedCategory: WikiCategory? = nil
    @State private var searchText = ""
    
    init(userID: String) {
        _storage = StateObject(wrappedValue: WikiStorage(userID: userID))
    }
    
    private var filteredEntries: [WikiEntry] {
        var result = storage.entries
        
        if let category = selectedCategory {
            result = result.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // MARK: Header
                headerSection
                
                // MARK: Kategorie-Filter
                categoryFilterSection
                
                // MARK: Einträge Grid
                if filteredEntries.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredEntries) { entry in
                            WikiEntryCard(entry: entry, storage: storage)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Partner-Wiki")
        .searchable(text: $searchText, prompt: "Suchen...")
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
            CreateWikiEntryView(storage: storage)
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 36))
                .foregroundColor(.accentColor)
            
            Text("Dein privater Notizbereich")
                .font(.headline)
            
            Text("Nur du kannst diese Einträge sehen. Sie werden niemals mit deinem Partner synchronisiert.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.top, 10)
        .padding(.bottom, 5)
    }
    
    // MARK: - Kategorie Filter
    private var categoryFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                // "Alle" Button
                CategoryPill(
                    title: "Alle",
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedCategory == nil
                ) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedCategory = nil
                    }
                }
                
                ForEach(WikiCategory.allCases) { category in
                    let count = storage.entries(for: category).count
                    if count > 0 {
                        CategoryPill(
                            title: category.rawValue,
                            icon: category.icon,
                            count: count,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 50))
                .foregroundColor(Color(UIColor.tertiaryLabel))
            
            Text("Noch keine Einträge")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Speichere hier wichtige Infos über deinen Partner: Ringgrößen, Lieblingsblumen, Geschenkideen...")
                .font(.subheadline)
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showingCreateSheet = true
            } label: {
                Label("Ersten Eintrag erstellen", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.accentColor)
                    .clipShape(Capsule())
            }
            .padding(.top, 10)
        }
        .padding(.vertical, 60)
    }
}

// MARK: - Kategorie Pill
struct CategoryPill: View {
    let title: String
    let icon: String
    var count: Int? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let count = count {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(UIColor.secondarySystemFill))
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
