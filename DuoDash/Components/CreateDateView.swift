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
    @State private var priceLevel: Double = 1
    @State private var selectedCategory: DateCategory = .romantic
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @State private var imageData: Data? = nil
    @ObservedObject var space: SharedSpace
    
    
    var body: some View {
        ScrollView {
            VStack {
                
                Spacer()
                
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.accentColor)
                
                Text("Neue Date-Idee")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("Erstelle eine neue Idee für ein romantisches Date mit deinem Partner!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                
                Spacer()
                    .padding(.top, 30)
                
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    if imageData == nil {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 40))
                            .foregroundColor(.accentColor)
                            .frame(width: 80, height: 80)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    } else {
                        Image(uiImage: UIImage(data: imageData!)!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipped()
                            .cornerRadius(8)
                    }
                }
                
                Spacer()
                    .padding(.bottom, 30)
                
                TextField("Titel", text: $title)
                    .padding(16)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                TextField("URL / Web", text: $url)
                    .padding(16)
                    .background(Color.gray.opacity(0.2))
                    .textInputAutocapitalization(.never)
                    .textContentType(.URL)
                    .cornerRadius(8)
                
                TextField("Ort", text: $location)
                    .padding(16)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                
                TextField("Beschreibung", text: $text)
                    .padding(16)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .lineLimit(3...6)
                
                Picker("Kategorie", selection: $selectedCategory) {
                    Text("Allgemein").tag(DateCategory.all)
                    Text("Romantisch").tag(DateCategory.romantic)
                    Text("Abenteuer").tag(DateCategory.adventurous)
                    Text("Entspannt").tag(DateCategory.relaxed)
                }
                .pickerStyle(.segmented)
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                
                Slider(
                    value: $priceLevel,
                    in: 1...5,
                    step: 1) {
                        Text("Preis-Niveau")
                    } minimumValueLabel: {
                        Image(systemName: "eurosign.circle")
                    } maximumValueLabel: {
                        Image(systemName: "eurosign.circle.fill")
                    }
                
                Button {
                    let d = DateIdea(context: viewContext)
                    d.text = text
                    d.title = title
                    d.location = location
                    d.isDone = false
                    d.id = UUID()
                    d.urlString = url
                    d.priceLevel = Int16(priceLevel)
                    d.category = selectedCategory.rawValue
                    if let imageData = imageData {
                        d.imageData = imageData
                    }
                    d.space = space
                    
                    space.addToDateIdeas(d)
                    
                    do {
                        try viewContext.save()
                    } catch {
                        
                    }
                    
                    dismiss()
                } label: {
                    Text("Neues Date erstellen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(title.isEmpty ? Color.accent.opacity(0.5) : Color.accent)
                        .cornerRadius(12)
                }
                .disabled(title.isEmpty || text.isEmpty)
                .padding(.horizontal, 40)
                .padding(.top, 40)
                
                
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                        .foregroundStyle(.gray)
                        .bold()
                }
                .padding(.horizontal, 40)
                .padding(.top, 10)
                Spacer()
            }
        }
        .padding()
        .onChange(of: selectedPhoto) {
            Task {
                if let loaded = try? await selectedPhoto?.loadTransferable(type: Image.self) {
                    imageData = try? await loaded.exported(as: .png)
                } else {
                    
                }
            }
        }
    }
}

#Preview {
    CreateDateView(space: SharedSpace())
}

