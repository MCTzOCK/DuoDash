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
    @State private var targetDate: Date = Date()
    @State private var imageData: Data? = nil
    @State private var selectedPhoto: PhotosPickerItem? = nil
    
    @ObservedObject var space: SharedSpace
    
    var body: some View {
        VStack(spacing: 0) {
            
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
                                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.secondary.opacity(0.2), lineWidth: 1))
                                    .shadow(radius: 5)
                            } else {
                                VStack(spacing: 8) {
                                    // Passendes Icon für Countdowns
                                    Image(systemName: "hourglass.badge.plus")
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
                        Text("Neuer Countdown")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Erstelle einen neuen Countdown, damit ihr euch gemeinsam auf ein besonderes Ereignis freuen könnt.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    .frame(maxWidth: .infinity)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden, edges: .all)
                
                // MARK: - 2. Details (Eingabefelder)
                Section(header: Text("Details")) {
                    TextField("Titel", text: $title)
                        .font(.headline)
                    
                    DatePicker("Datum & Uhrzeit",
                               selection: $targetDate,
                               in: Date()...,
                               displayedComponents: [.date, .hourAndMinute])
                }
            }
            
            // MARK: - 3. Buttons am unteren Rand
            VStack(spacing: 16) {
                Button {
                    saveNewCountdown()
                } label: {
                    Text("Neuen Countdown erstellen")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        // Color.accentColor ist die sichere native Variante
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
    private func saveNewCountdown() {
        let newCountdown = Countdown(context: viewContext)
        newCountdown.id = UUID()
        newCountdown.title = title
        newCountdown.targetDate = targetDate
        
        if let imgData = imageData {
            newCountdown.imageData = imgData
        }
        
        newCountdown.space = space
        
        do {
            CoreDataManager.shared.save()
            dismiss()
        } catch {
            print("Fehler beim Speichern des Countdowns: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CreateCountdownView(space: SharedSpace())
}
