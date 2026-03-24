//
//  CreateCountdownView.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI
import CoreData
import PhotosUI


struct CreateCountdownView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var title: String = ""
    @State private var targetData: Date = Date()
    @State private var imageData: Data? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil
    @ObservedObject var space: SharedSpace
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Image(systemName: "hourglass.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Neuer Countdown")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Erstelle einen neuen Countdown, damit ihr euch gemeinsam auf ein besonderes Ereignis freuen könnt.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
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
            
            TextField("Titel", text: $title)
                .padding(16)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            DatePicker("Datum & Uhrzeit", selection: $targetData, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                .padding(16)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                .padding(.top, 10)
                
            
            
            Button {
                
                let newCountdown = Countdown(context: viewContext)
                newCountdown.title = title
                newCountdown.targetDate = targetData
                if let imageData = imageData {
                    newCountdown.imageData = imageData
                }
                newCountdown.id = UUID()
                newCountdown.space = space
                
                space.countdowns?.adding(newCountdown)
                
                do {
                    try viewContext.save()
                } catch {
                    print("Failed to create countdown \(error.localizedDescription)")
                }
                
                dismiss()
            } label: {
                Text("Neuen Countdown erstellen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(title.isEmpty ? Color.accent.opacity(0.5) : Color.accent)
                    .cornerRadius(12)
            }
            .disabled(title.isEmpty)
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
    CreateCountdownView(space: SharedSpace())
}
