//
//  ListDetailView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//
import SwiftUI
import CoreData
import FoundationModels


struct ListDetailView: View {
    
    @ObservedObject var container: ListContainer
    @ObservedObject var space: SharedSpace
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var coreData = CoreDataManager.shared
    
    @FetchRequest var items: FetchedResults<ListItem>
    
    @State private var showingCreateSheet = false
    @State private var itemToEdit: ListItem? = nil
    @State private var showingEditSheet = false
    
    @State private var showingSpinnerSheet = false
    
    // Quick-Add direkt im View
    @State private var quickAddTitle: String = ""
    @FocusState private var isQuickAddFocused: Bool
    
    init(container: ListContainer, space: SharedSpace) {
        self.container = container
        self.space = space
        _items = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \ListItem.isCompleted, ascending: true),
                NSSortDescriptor(keyPath: \ListItem.title, ascending: true)
            ],
            predicate: NSPredicate(format: "container == %@", container)
        )
    }
    
    private var pendingItems: [ListItem] {
        items.filter { !$0.isCompleted }
    }
    
    private var completedItems: [ListItem] {
        items.filter { $0.isCompleted }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                // MARK: Quick-Add Feld (ganz oben, immer sichtbar)
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.title3)
                        
                        TextField("Neuer Eintrag...", text: $quickAddTitle)
                            .font(.body)
                            .focused($isQuickAddFocused)
                            .onSubmit {
                                quickAdd()
                            }
                            .submitLabel(.done)
                        
                        if !quickAddTitle.isEmpty {
                            Button {
                                quickAdd()
                            } label: {
                                Text("Hinzufügen")
                                    .font(.subheadline)
                                    .bold()
                                    .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
                
                // MARK: Offene Items
                if !pendingItems.isEmpty {
                    Section(header: Text("Offen (\(pendingItems.count))")) {
                        ForEach(pendingItems) { item in
                            Button {
                                itemToEdit = item
                            } label: {
                                ListItemRow(item: item)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteItem(item)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                
                // MARK: Erledigte Items
                if !completedItems.isEmpty {
                    Section(header: Text("Erledigt (\(completedItems.count))")) {
                        ForEach(completedItems) { item in
                            Button {
                                itemToEdit = item
                            } label: {
                                ListItemRow(item: item)
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deleteItem(item)
                                } label: {
                                    Label("Löschen", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
                
                // MARK: Empty State
                if items.isEmpty {
                    Section {
                        VStack(spacing: 10) {
                            Image(systemName: container.symbol ?? "checklist")
                                .font(.system(size: 40))
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                            
                            Text("Diese Liste ist noch leer")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Nutze das Textfeld oben, um blitzschnell neue Einträge hinzuzufügen.")
                                .font(.subheadline)
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 30)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle(container.title ?? "Liste")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingSpinnerSheet = true
                } label: {
                    Image(systemName: "dice")
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showingEditSheet = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateListItemView(container: container)
        }
        .sheet(item: $itemToEdit) { item in
            ListItemDetailView(item: item, container: container)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditListView(container: container, space: space, dismissRootView: dismiss)
        }
        .sheet(isPresented: $showingSpinnerSheet) {
            NavigationStack {
                FortuneWheelView(
                    items: items.map { $0.title ?? "Unbenannter Eintrag" },
                    onResult: { result in
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Fertig") {
                            showingSpinnerSheet = false
                        }
                    }
                }
            }
        }
        .onChange(of: coreData.lastSyncUpdate) { _ in
            // Zwingt ALLE FetchRequests in diesem View, ihre Daten neu zu laden
            viewContext.refreshAllObjects()
        }
    }
    
    // MARK: Quick-Add Funktion
    private func quickAdd() {
        guard !quickAddTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        withAnimation {
            let newItem = ListItem(context: viewContext)
            newItem.id = UUID()
            newItem.title = quickAddTitle
            newItem.isCompleted = false
            newItem.container = container
            
            do {
                CoreDataManager.shared.save()
                quickAddTitle = ""
            } catch {
                print("Fehler beim Speichern: \(error.localizedDescription)")
            }
        }
    }
    
    private func deleteItem(_ item: ListItem) {
        withAnimation {
            viewContext.delete(item)
            do {
                CoreDataManager.shared.save()
            } catch {
                print("Fehler beim Löschen: \(error.localizedDescription)")
            }
        }
    }
}
