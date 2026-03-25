//
//  MemoryDetailView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//
import SwiftUI
import CoreData
import PhotosUI

struct MemoryDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var memory: Memory
    @ObservedObject var space: SharedSpace
    
    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var location: String = ""
    @State private var date: Date = Date()
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
                    
                    TextField("Was ist passiert?", text: $bodyText, axis: .vertical)
                        .lineLimit(4...10)
                }
                
                // MARK: Wann & Wo
                Section(header: Text("Wann & Wo")) {
                    DatePicker("Datum", selection: $date, displayedComponents: [.date])
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        TextField("Ort (optional)", text: $location)
                    }
                }
                
                // MARK: Löschen
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Erinnerung löschen")
                                .bold()
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Erinnerung bearbeiten")
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
                    deleteMemory()
                }
            } message: {
                Text("Möchtest du diese Erinnerung wirklich unwiderruflich löschen?")
            }
        }
    }
    
    private func loadData() {
        title = memory.title ?? ""
        bodyText = memory.bodyText ?? ""
        location = memory.location ?? ""
        date = memory.date ?? Date()
        imageData = memory.photoData
    }
    
    private func saveChanges() {
        memory.title = title
        memory.bodyText = bodyText.isEmpty ? nil : bodyText
        memory.location = location.isEmpty ? nil : location
        memory.date = date
        
        if let imgData = imageData {
            memory.photoData = imgData
        }
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
    
    private func deleteMemory() {
        viewContext.delete(memory)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Fehler beim Löschen: \(error.localizedDescription)")
        }
    }
}
