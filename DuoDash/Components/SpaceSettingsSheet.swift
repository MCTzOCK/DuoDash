//
//  SpaceSettingsSheet.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI
import SwiftEmojiPicker
import CoreData
import CloudKit

struct SpaceSettingsSheet: View {
    @Binding var isVisible: Bool
    @Binding var renameText: String
    @Binding var renameEmoji: String
    @Binding var joinDate: Date
    var space: SharedSpace
    var onSave: () -> Void
    
    @State private var showPicker = false
    
    @State private var isShowingShareSheet = false
    @State private var isSharing = false // Für den Lade-Spinner
    
    // Hier speichern wir den fertigen Share temporär
    @State private var activeShare: CKShare?
    @State private var activeContainer: CKContainer?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Name")) {
                    TextField("Name", text: $renameText)
                }
                Section(header: Text("Emoji")) {
                    Button(renameEmoji) {
                        showPicker = true
                    }
                    .emojiPicker(isPresented: $showPicker, selectedEmoji: $renameEmoji)
                    .padding(16)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                Section(header: Text("Unser Datum")) {
                    DatePicker("Unser Datum", selection: $joinDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                }
                Section(header: Text("Partner Einladen")) {
                    Button(action: {
                        startSharingProcess()
                    }) {
                        HStack {
                            if isSharing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 5)
                            } else {
                                Image(systemName: "person.badge.plus")
                            }
                            Text(isSharing ? "Erstelle Link..." : "Partner einladen")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    .disabled(isSharing) // Button sperren, während geladen wird
                    .padding(.horizontal, 40)
                    .padding(.bottom, 50)
                }
            }
            .navigationTitle("Einstellungen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { isVisible = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onSave()
                    } label: {
                        Label("Speichern", systemImage: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .sheet(isPresented: $isShowingShareSheet) {
                if let share = activeShare, let container = activeContainer {
                    CloudSharingView(share: share, container: container)
                }
            }
        }
    }
    
    private func startSharingProcess() {
        isSharing = true
        
        CoreDataManager.shared.createShare(for: space) { share, container, error in
            isSharing = false
            
            if let error = error {
                print("❌ Sharing im UI fehlgeschlagen: \(error.localizedDescription)")
                // Hier könntest du später einen Alert für den User einbauen
                return
            }
            
            if let share = share, let container = container {
                self.activeShare = share
                self.activeContainer = container
                self.isShowingShareSheet = true // Jetzt das Sheet öffnen!
            }
        }
    }
}
