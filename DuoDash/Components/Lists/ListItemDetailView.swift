//
//  ListItemDetailView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI
import CoreData
import PhotosUI

struct ListItemDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var item: ListItem
    @ObservedObject var container: ListContainer
    
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var isCompleted: Bool = false
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    @State private var showingDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: Foto
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
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                                    .shadow(radius: 5)
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.circle.fill")
                                        .font(.system(size: 50))
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
                }
                .listRowBackground(Color.clear)
                
                // MARK: Details
                Section(header: Text("Details")) {
                    TextField("Titel", text: $title)
                        .font(.headline)
                    
                    TextField("Notiz (optional)", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // MARK: Status
                Section {
                    Toggle(isOn: $isCompleted) {
                        Label(
                            "Erledigt",
                            systemImage: isCompleted ? "checkmark.circle.fill" : "circle"
                        )
                        .foregroundColor(isCompleted ? .green : .primary)
                    }
                    .tint(.green)
                }
                
                // MARK: Löschen
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Eintrag löschen")
                                .bold()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Eintrag bearbeiten")
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
            .onChange(of: selectedPhoto) { newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        imageData = data
                    }
                }
            }
            .alert("Bist du sicher?", isPresented: $showingDeleteAlert) {
                Button("Abbrechen", role: .cancel) { }
                Button("Löschen", role: .destructive) {
                    deleteItem()
                }
            } message: {
                Text("Möchtest du diesen Eintrag wirklich unwiderruflich löschen?")
            }
        }
    }
    
    private func loadData() {
        title = item.title ?? ""
        text = item.text ?? ""
        isCompleted = item.isCompleted
        imageData = item.imageData
    }
    
    private func saveChanges() {
        item.title = title
        item.text = text.isEmpty ? nil : text
        item.isCompleted = isCompleted
        
        if let imgData = imageData {
            item.imageData = imgData
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
    
    private func deleteItem() {
        viewContext.delete(item)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Fehler beim Löschen: \(error.localizedDescription)")
        }
    }
}
