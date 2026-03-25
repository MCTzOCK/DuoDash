//
//  CreateDateView.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI
import CoreData
import PhotosUI

struct CreateDateView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var title: String = ""
    @State private var url: String = ""
    @State private var location: String = ""
    @State private var text: String = ""
    @State private var priceLevel: Double = 1.0
    @State private var selectedCategory: DateCategory = .romantic
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    
    @ObservedObject var space: SharedSpace
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Optional: Ein kleiner Titel, da keine NavigationBar vorhanden ist
            /*Text("Neue Date-Idee")
                .font(.headline)
                .padding(.top, 20)
                .padding(.bottom, 10)
            */
            
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
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
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
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                    
                    VStack {
                        Text("Neue Date-Idee")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Erstelle eine neue Idee für ein romantisches Date mit deinem Partner!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden, edges: .all)
                
                // MARK: - 2. Basis-Informationen
                Section(header: Text("Details")) {
                    TextField("Titel", text: $title)
                        .font(.headline)
                    
                    TextField("Beschreibung", text: $text, axis: .vertical)
                        .lineLimit(3...8)
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
                        
                        Slider(value: $priceLevel, in: 1...5,step: 1) {
                            Text("Preis-Niveau")
                        } minimumValueLabel: {
                            Image(systemName: "eurosign.circle")
                        } maximumValueLabel: {
                            Image(systemName: "eurosign.circle.fill")
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            // MARK: - Deine originalen Buttons am unteren Rand
            VStack(spacing: 16) {
                Button {
                    saveNewDate()
                } label: {
                    Text("Neues Date erstellen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(title.isEmpty ? Color.accent.opacity(0.5) : Color.accent)
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
            .background(Color(UIColor.systemGroupedBackground)) // Passt sich der Farbe der Form an
        }
        // Foto verarbeiten
        .onChange(of: selectedPhoto) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
    
    // MARK: - Speicher-Logik
    private func saveNewDate() {
        let newIdea = DateIdea(context: viewContext)
        newIdea.id = UUID()
        newIdea.title = title
        newIdea.text = text
        newIdea.location = location
        newIdea.urlString = url
        newIdea.priceLevel = Int16(priceLevel)
        newIdea.isDone = false
        newIdea.category = selectedCategory.rawValue
        
        if let imgData = imageData {
            newIdea.imageData = imgData
        }
        
        newIdea.space = space
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
    
}

#Preview {
    CreateDateView(space: SharedSpace())
}

