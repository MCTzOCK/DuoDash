//
//  CreateListItemView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//

import SwiftUI
import CoreData
import PhotosUI

struct CreateListItemView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var title: String = ""
    @State private var text: String = ""
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    
    @ObservedObject var container: ListContainer
    
    var body: some View {
        VStack(spacing: 0) {
            
            Form {
                // MARK: Header
                Section {
                    VStack {
                        Image(systemName: container.symbol ?? "checklist")
                            .font(.system(size: 60))
                            .foregroundColor(.accentColor)
                        
                        Text("Neuer Eintrag")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Füge einen neuen Eintrag zu \"\(container.title ?? "Liste")\" hinzu.")
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
                    
                    TextField("Notiz (optional)", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // MARK: Foto (Optional)
                Section(header: Text("Foto (optional)")) {
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedPhoto, matching: .images) {
                            if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .shadow(radius: 4)
                            } else {
                                VStack(spacing: 6) {
                                    Image(systemName: "camera.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.accentColor)
                                    Text("Foto")
                                        .font(.caption)
                                        .bold()
                                }
                                .frame(width: 100, height: 100)
                                .background(Color(UIColor.secondarySystemFill))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        Spacer()
                    }
                }
            }
            
            // MARK: Buttons
            VStack(spacing: 16) {
                Button {
                    saveNewItem()
                } label: {
                    Text("Eintrag hinzufügen")
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
    
    private func saveNewItem() {
        let newItem = ListItem(context: viewContext)
        newItem.id = UUID()
        newItem.title = title
        newItem.text = text.isEmpty ? nil : text
        newItem.isCompleted = false
        newItem.container = container
        
        if let imgData = imageData {
            newItem.imageData = imgData
        }
        
        do {
            CoreDataManager.shared.save()
            dismiss()
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
}
