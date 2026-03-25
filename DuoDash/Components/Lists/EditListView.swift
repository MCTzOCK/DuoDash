//
//  EditListView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//
import SwiftUI
import CoreData

struct EditListView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var container: ListContainer
    @ObservedObject var space: SharedSpace
    var dismissRootView: DismissAction
    
    @State private var title: String = ""
    @State private var selectedSymbol: String = "cart.fill"
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: Vorschau des gewählten Symbols
                Section {
                    HStack {
                        Spacer()
                        Image(systemName: selectedSymbol)
                            .font(.system(size: 50))
                            .foregroundColor(.accentColor)
                            .frame(width: 80, height: 80)
                            .background(Color.accentColor.opacity(0.15))
                            .clipShape(Circle())
                            .animation(.easeInOut(duration: 0.15), value: selectedSymbol)
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
                .listRowBackground(Color.clear)
                
                // MARK: Details
                Section(header: Text("Details")) {
                    TextField("Titel", text: $title)
                        .font(.headline)
                }
                
                // MARK: Symbol-Picker (Wiederverwendbare Komponente)
                Section(header: Text("Symbol ändern")) {
                    SymbolPickerGrid(selectedSymbol: $selectedSymbol)
                }
                
                // MARK: Statistik
                Section(header: Text("Info")) {
                    let allItems = (container.items?.allObjects as? [ListItem]) ?? []
                    let completed = allItems.filter { $0.isCompleted }.count
                    
                    HStack {
                        Label("Einträge gesamt", systemImage: "number")
                        Spacer()
                        Text("\(allItems.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Label("Davon erledigt", systemImage: "checkmark.circle")
                        Spacer()
                        Text("\(completed)")
                            .foregroundColor(.green)
                    }
                }
                
                // MARK: Erledigte löschen
                if let items = container.items?.allObjects as? [ListItem],
                   items.contains(where: { $0.isCompleted }) {
                    Section {
                        Button(role: .destructive) {
                            clearCompleted()
                        } label: {
                            HStack {
                                Spacer()
                                Label("Erledigte Einträge entfernen", systemImage: "trash")
                                Spacer()
                            }
                        }
                    }
                }
                
                // MARK: Liste löschen
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Gesamte Liste löschen")
                                .bold()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Liste bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveChanges()
                    }
                    .bold()
                    .disabled(title.isEmpty)
                }
            }
            .onAppear {
                loadData()
            }
            .alert("Liste wirklich löschen?", isPresented: $showingDeleteAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Löschen", role: .destructive) {
                    deleteList()
                }
            } message: {
                Text("Die gesamte Liste inklusive aller Einträge wird unwiderruflich gelöscht.")
            }
        }
    }
    
    // MARK: Hilfsfunktionen
    
    private func loadData() {
        title = container.title ?? ""
        selectedSymbol = container.symbol ?? "cart.fill"
    }
    
    private func saveChanges() {
        container.title = title
        container.symbol = selectedSymbol
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
    
    private func clearCompleted() {
        guard let items = container.items?.allObjects as? [ListItem] else { return }
        
        withAnimation {
            for item in items where item.isCompleted {
                viewContext.delete(item)
            }
            
            do {
                try viewContext.save()
            } catch {
                print("Fehler beim Löschen: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteList() {
        viewContext.delete(container)
        
        do {
            try viewContext.save()
            dismiss()
            dismissRootView()
        } catch {
            print("Fehler beim Löschen: \(error.localizedDescription)")
        }
    }
}
