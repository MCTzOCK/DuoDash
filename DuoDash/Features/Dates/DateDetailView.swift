//
//  DateDetailView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI
import CoreData
import PhotosUI

struct DateDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var dateIdea: DateIdea
    @ObservedObject var space: SharedSpace
    
    // Lokale States für das Editieren
    @State private var title: String = ""
    @State private var url: String = ""
    @State private var location: String = ""
    @State private var text: String = ""
    @State private var priceLevel: Double = 1
    @State private var selectedCategory: DateCategory = .romantic // Angenommen, das Enum existiert in deinem Code
    @State private var isDone: Bool = false
    
    // Foto-Management
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    
    // Alert State für das Löschen
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Form {
            // MARK: - 1. Foto Sektion (Header)
            Section {
                HStack {
                    Spacer()
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                                .shadow(radius: 5)
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "camera.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.accentColor)
                                Text("Foto hinzufügen")
                                    .font(.caption)
                                    .bold()
                            }
                            .frame(width: 120, height: 120)
                            .background(Color(UIColor.secondarySystemFill))
                            .clipShape(Circle())
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
            }
            .listRowBackground(Color.clear) // Macht den Hintergrund unsichtbar, damit das Bild "schwebt"
            
            // MARK: - 2. Basis-Informationen
            Section(header: Text("Details")) {
                TextField("Titel", text: $title)
                    .font(.headline)
                
                TextField("Beschreibung", text: $text, axis: .vertical)
                    .lineLimit(3...8) // Erlaubt mehrzeiligen Text (wächst automatisch)
            }
            
            // MARK: - 3. Zusatz-Infos
            Section(header: Text("Ort & Web")) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.accentColor)
                        .frame(width: 24)
                    TextField("Ort", text: $location)
                }
                
                HStack {
                    Image(systemName: "link")
                        .foregroundColor(.accentColor)
                        .frame(width: 24)
                    TextField("URL", text: $url)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                }
            }
            
            // MARK: - 4. Metadaten
            Section(header: Text("Kategorisierung")) {
                Picker("Kategorie", selection: $selectedCategory) {
                    Text("Allgemein").tag(DateCategory.all)
                    Text("Romantisch").tag(DateCategory.romantic)
                    Text("Abenteuer").tag(DateCategory.adventurous)
                    Text("Entspannt").tag(DateCategory.relaxed)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Preis-Niveau: \(Int(priceLevel))")
                        .font(.subheadline)
                    Slider(
                        value: $priceLevel,
                        in: 1.0...5.0, // WICHTIG: .0 hinzufügen!
                        step: 1.0      // WICHTIG: .0 hinzufügen!
                    ) {
                        Text("Preis-Niveau")
                    } minimumValueLabel: {
                        Image(systemName: "eurosign.circle")
                            .foregroundColor(.secondary)
                    } maximumValueLabel: {
                        Image(systemName: "eurosign.circle.fill")
                            .foregroundColor(.primary)
                    }
                }
                .padding(.vertical, 4)
            }
            
            // MARK: - 5. Status
            Section {
                Toggle(isOn: $isDone) {
                    Label("Als erledigt markieren", systemImage: isDone ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(isDone ? .green : .primary)
                }
                .tint(.green)
            }
            
            // MARK: - 6. Löschen (Destructive)
            Section {
                Button(role: .destructive) {
                    showingDeleteAlert = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Date-Idee löschen")
                            .bold()
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Date bearbeiten")
        .navigationBarTitleDisplayMode(.inline)
        // Lädt die bestehenden Daten in die UI
        .onAppear {
            loadInitialData()
        }
        // Foto verarbeiten
        .onChange(of: selectedPhoto) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
        
        // Toolbar für den Speichern-Button
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Speichern") {
                    saveChanges()
                }
                .bold()
                .disabled(title.isEmpty) // Verhindert Speichern ohne Titel
            }
        }
        // Sicherheitsabfrage vor dem Löschen
        .alert("Bist du sicher?", isPresented: $showingDeleteAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Löschen", role: .destructive) {
                deleteIdea()
            }
        } message: {
            Text("Möchtest du diese Idee wirklich unwiderruflich löschen?")
        }
    }
    
    // MARK: - Hilfsfunktionen
    
    private func loadInitialData() {
        title = dateIdea.title ?? ""
        text = dateIdea.text ?? ""
        location = dateIdea.location ?? ""
        url = dateIdea.urlString ?? ""
        priceLevel = Double(dateIdea.priceLevel > 0 ? dateIdea.priceLevel : 1)
        isDone = dateIdea.isDone
        imageData = dateIdea.imageData
        
        // (Vorausgesetzt dein Model hat die Eigenschaft 'category' wie in deinem CreateView)
        /*
         if let catRaw = dateIdea.category, let cat = DateCategory(rawValue: catRaw) {
         selectedCategory = cat
         }
         */
    }
    
    private func saveChanges() {
        dateIdea.title = title
        dateIdea.text = text
        dateIdea.location = location
        dateIdea.urlString = url
        dateIdea.priceLevel = Int16(priceLevel)
        dateIdea.isDone = isDone
        if let imageData = imageData {
            dateIdea.imageData = imageData
        }
        
        // dateIdea.category = selectedCategory.rawValue
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Fehler beim Aktualisieren: \(error.localizedDescription)")
        }
    }
    
    private func deleteIdea() {
        viewContext.delete(dateIdea)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Fehler beim Löschen: \(error.localizedDescription)")
        }
    }
}
