//
//  CreateMemoryView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//
import SwiftUI
import PhotosUI
import CoreData


struct CreateMemoryView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var location: String = ""
    @State private var date: Date = Date()
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    
    @ObservedObject var space: SharedSpace
    
    var body: some View {
        VStack(spacing: 0) {
            
            Form {
                // MARK: Header
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
                                    Image(systemName: "photo.on.rectangle.angled")
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
                    
                    VStack {
                        Text("Neue Erinnerung")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Haltet einen besonderen Moment für immer fest.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden, edges: .all)
                
                // MARK: Details
                Section(header: Text("Details")) {
                    TextField("Titel", text: $title)
                        .font(.headline)
                    
                    TextField("Was ist passiert?", text: $bodyText, axis: .vertical)
                        .lineLimit(4...10)
                }
                
                // MARK: Ort & Datum
                Section(header: Text("Wann & Wo")) {
                    DatePicker("Datum", selection: $date, displayedComponents: [.date])
                    
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .foregroundColor(.accentColor)
                            .frame(width: 24)
                        TextField("Ort (optional)", text: $location)
                    }
                }
            }
            
            // MARK: Buttons
            VStack(spacing: 16) {
                Button {
                    saveNewMemory()
                } label: {
                    Text("Erinnerung speichern")
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
        .onChange(of: selectedPhoto) { newValue in
            Task {
                if let data = try? await newValue?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
    }
    
    private func saveNewMemory() {
        let newMemory = Memory(context: viewContext)
        newMemory.id = UUID()
        newMemory.title = title
        newMemory.bodyText = bodyText.isEmpty ? nil : bodyText
        newMemory.location = location.isEmpty ? nil : location
        newMemory.date = date
        newMemory.space = space
        
        if let imgData = imageData {
            newMemory.photoData = imgData
        }
        
        do {
            CoreDataManager.shared.save()
            dismiss()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
}
