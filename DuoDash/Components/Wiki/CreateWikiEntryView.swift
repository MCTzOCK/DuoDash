//
//  CreateWikiEntryView.swift
//  DuoDash
//
//  Created by Ben Siebert on 27.03.26.
//


import SwiftUI
import PhotosUI

struct CreateWikiEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var storage: WikiStorage
    
    @State private var selectedType: WikiEntryType = .text
    @State private var selectedCategory: WikiCategory = .other
    @State private var title = ""
    @State private var content = ""
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    
    private var canSave: Bool {
        !title.isEmpty && (selectedType != .image || imageData != nil)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: Typ-Auswahl
                Section(header: Text("Art des Eintrags")) {
                    Picker("Typ", selection: $selectedType) {
                        ForEach(WikiEntryType.allCases) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets())
                }
                
                // MARK: Kategorie
                Section(header: Text("Kategorie")) {
                    Picker("Kategorie", selection: $selectedCategory) {
                        ForEach(WikiCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
                
                // MARK: Titel
                Section(header: Text("Titel")) {
                    TextField(titlePlaceholder, text: $title)
                }
                
                // MARK: Inhalt (abhängig vom Typ)
                switch selectedType {
                case .text:
                    Section(header: Text("Notiz")) {
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                    }
                    
                case .link:
                    Section(header: Text("URL")) {
                        TextField("https://...", text: $content)
                            .keyboardType(.URL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                case .size:
                    Section(header: Text("Größenangabe")) {
                        TextField("z.B. 38, M, 17mm", text: $content)
                    }
                    
                case .image:
                    Section(header: Text("Bild")) {
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                                    .cornerRadius(12)
                            } else {
                                HStack {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.title2)
                                    Text("Bild auswählen")
                                }
                                .foregroundColor(.accentColor)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 40)
                                .background(Color(UIColor.tertiarySystemFill))
                                .cornerRadius(12)
                            }
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                        
                        if imageData != nil {
                            TextField("Bildunterschrift (optional)", text: $content)
                        }
                    }
                }
            }
            .navigationTitle("Neuer Eintrag")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        saveEntry()
                    }
                    .bold()
                    .disabled(!canSave)
                }
            }
            .onChange(of: selectedPhoto) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
        }
    }
    
    private var titlePlaceholder: String {
        switch selectedType {
        case .text: return "z.B. Lieblingsrestaurant"
        case .link: return "z.B. Wunschliste Amazon"
        case .size: return "z.B. Ringgröße"
        case .image: return "z.B. Traumkleid"
        }
    }
    
    private func saveEntry() {
        let entry = WikiEntry(
            type: selectedType,
            category: selectedCategory,
            title: title,
            content: content,
            imageData: imageData
        )
        
        storage.addEntry(entry)
        
        // Haptisches Feedback
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        dismiss()
    }
}
