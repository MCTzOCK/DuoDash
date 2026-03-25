//
//  DateOverviewView.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI
import CoreData

struct DateOverviewView: View {
    
    @ObservedObject var space: SharedSpace
    
    @State private var showCreateSheet = false
    @State private var searchText = ""
    
    @State private var selectedCategory: DateCategory = .all
    @State private var selectedSort: DateSorting = .asc
    
    var filteredAndSortedDates: [DateIdea] {
        // 1. Safe unwrapping (avoid force cast 'as!')
        let dates = space.dateIdeas?.allObjects as? [DateIdea] ?? []
        
        // 2. Filter
        let filtered = dates.filter { dateIdea in
            // Logic: Must match Search AND (Match Category OR Category is All)
            
            // Check Search
            let matchesSearch = searchText.isEmpty ||
            (dateIdea.title?.localizedCaseInsensitiveContains(searchText) == true) ||
            (dateIdea.text?.localizedCaseInsensitiveContains(searchText) == true)
            
            // Check Category
            let matchesCategory = selectedCategory == .all || dateIdea.category == selectedCategory.rawValue
            
            return matchesSearch && matchesCategory
        }
        
        // 3. Sort (Core Data sets are unordered, so you MUST sort them)
        return filtered.sorted { lhs, rhs in
            switch selectedSort {
            case .asc:
                return (lhs.title ?? "") < (rhs.title ?? "")
            case .desc:
                return (lhs.title ?? "") > (rhs.title ?? "")
            case .priceAsc:
                return lhs.priceLevel < rhs.priceLevel
            case .priceDesc:
                return lhs.priceLevel > rhs.priceLevel
            case .notDone:
                if lhs.isDone == rhs.isDone {
                    return (lhs.title ?? "") < (rhs.title ?? "")
                }
                return lhs.isDone == false
            case .done:
                if lhs.isDone == rhs.isDone {
                    return (lhs.title ?? "") < (rhs.title ?? "")
                }
                return lhs.isDone == true
            default:
                return (lhs.title ?? "") < (rhs.title ?? "")
            }
        }
    }
    
    
    
    var body: some View {
        VStack(spacing: 20) {
            Picker("Kategorie", selection: $selectedCategory) {
                ForEach(DateCategory.allCases, id: \.self) { category in
                    Text(category.rawValue)
                        .tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .id("categoryPicker")
            .onChange(of: selectedCategory) { _ in
                searchText = ""
            }
            ScrollView {
                
                ForEach(filteredAndSortedDates) { dateIdea in
                    DateCardView(dateIdea: dateIdea, space: space)
                }
                
                if space.dateIdeas?.allObjects.count == 0 {
                    DateUnavailableView(showCreateSheet: $showCreateSheet)
                }
            }
        }
        .navigationTitle("Dates")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Menu {
                    Picker("Sortieren", selection: $selectedSort) {
                        Text(DateSorting.asc.rawValue).tag(DateSorting.asc)
                        Text(DateSorting.desc.rawValue).tag(DateSorting.desc)
                        Text(DateSorting.priceAsc.rawValue).tag(DateSorting.priceAsc)
                        Text(DateSorting.priceDesc.rawValue).tag(DateSorting.priceDesc)
                        Text(DateSorting.notDone.rawValue).tag(DateSorting.notDone)
                        Text(DateSorting.done.rawValue).tag(DateSorting.done)
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateDateView(space: space)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Date-Ideen durchsuchen")
    }
}


private struct DateUnavailableView: View {
    
    @Binding var showCreateSheet: Bool
    
    
    var body: some View {
        ContentUnavailableView {
            Label("Keine Dates", systemImage: "wineglass")
        } description: {
            VStack(spacing: 20) {
                Text("Es wurden keine Date-Ideen erstellt. Tippe auf das Plus-Symbol, um euer erstes Date zu planen!")
                Button() {
                    showCreateSheet = true
                } label: {
                    Label("Date erstellen", systemImage: "plus")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.accent)
                        .cornerRadius(12)
                }
            }
        }
    }
}
