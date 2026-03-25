//
//  CountdownDetailView.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI
import CoreData
import PhotosUI

struct CountdownDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var space: SharedSpace
    @ObservedObject var countdown: Countdown
    
    @State private var title: String = ""
    @State private var targetDate: Date? = nil
    @State private var imageData: Data? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    var body: some View {
        VStack {
            ZStack {
                Image(uiImage: UIImage(data: countdown.imageData ?? Data()) ?? UIImage())
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .blur(radius: 4)
                CountdownCard(countdown: countdown)
            }
            Form {
                Section(header: Text("Titel")) {
                    TextField("Titel", text: $title)
                        .onChange(of: title) { newValue in
                            countdown.title = newValue
                            saveContext()
                        }
                }
                
                Section(header: Text("Zieldatum")) {
                    DatePicker("Zieldatum", selection: Binding(
                        get: { targetDate ?? Date() },
                        set: { newValue in
                            targetDate = newValue
                            countdown.targetDate = newValue
                            saveContext()
                        }
                    ), displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Bild")) {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if let data = imageData {
                            Image(uiImage: UIImage(data: imageData ?? Data()) ?? UIImage())
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(10)
                        } else {
                            Image(systemName: "photo.on.rectangle")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(.accentColor)
                                .padding()
                        }
                    }
                }
                Section(header: Text("Löschen")) {
                    Button(role: .destructive) {
                        space.removeFromCountdowns(countdown)
                        viewContext.delete(countdown)
                        saveContext()
                        dismiss()
                    } label: {
                        Label("Countdown löschen", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle(countdown.title ?? "Countdown")
        .onAppear {
            title = countdown.title ?? ""
            if let date = countdown.targetDate {
                targetDate = date
            }
            if let data = countdown.imageData {
                imageData = data
            }
        }
        .onChange(of: selectedPhoto) {
            Task {
                if let loaded = try? await selectedPhoto?.loadTransferable(type: Image.self) {
                    imageData = try? await loaded.exported(as: .png)
                    countdown.imageData = imageData
                    saveContext()
                } else {
                    imageData = nil
                }
            }
        }
    }
    
    func saveContext() {
        do {
            CoreDataManager.shared.save()
            viewContext.refresh(space, mergeChanges: true)
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
