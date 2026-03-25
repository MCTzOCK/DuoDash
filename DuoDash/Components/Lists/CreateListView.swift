//
//  CreateListView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//
import SwiftUI
import CoreData
import PhotosUI


struct CreateListView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var title: String = ""
    @State private var selectedSymbol: String = "cart.fill"
    
    @ObservedObject var space: SharedSpace
    
    var body: some View {
        VStack(spacing: 0) {
            
            Form {
                // MARK: Header
                Section {
                    VStack {
                        Image(systemName: selectedSymbol)
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                            .animation(.easeInOut(duration: 0.15), value: selectedSymbol)
                        
                        Text("Neue Liste")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Erstelle eine geteilte Liste für euren Alltag.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden, edges: .all)
                
                // MARK: Details
                Section(header: Text("Details")) {
                    TextField("Titel", text: $title)
                        .font(.headline)
                }
                
                // MARK: Symbol-Picker (REPARIERT)
                Section(header: Text("Symbol wählen")) {
                    SymbolPickerGrid(selectedSymbol: $selectedSymbol)
                }
            }
            
            // MARK: Buttons
            VStack(spacing: 16) {
                Button {
                    saveNewList()
                } label: {
                    Text("Neue Liste erstellen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(title.isEmpty ? Color.accentColor.opacity(0.5) : Color.accentColor)
                        .cornerRadius(12)
                }
                .disabled(title.isEmpty)
                
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                        .foregroundStyle(.gray)
                        .bold()
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
            .padding(.bottom, 20)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    private func saveNewList() {
        let newList = ListContainer(context: viewContext)
        newList.id = UUID()
        newList.title = title
        newList.symbol = selectedSymbol
        newList.space = space
        
        do {
            CoreDataManager.shared.save()
            dismiss()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
}
