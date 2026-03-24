//
//  SpaceSettingsSheet.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI
import SwiftEmojiPicker

struct SpaceSettingsSheet: View {
    @Binding var isVisible: Bool
    @Binding var renameText: String
    @Binding var renameEmoji: String
    @Binding var joinDate: Date
    var onSave: () -> Void
    
    @State private var showPicker = false
    
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
                    DatePicker("Unser Datum", selection: $joinDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
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
        }
    }
}
