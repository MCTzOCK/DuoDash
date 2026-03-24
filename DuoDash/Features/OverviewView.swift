//
//  OverviewView.swift
//  DuoDash
//
//  Created by Ben Siebert on 23.03.26.
//

import SwiftUI
import CoreData
import SwiftEmojiPicker

struct OverviewView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SharedSpace.joinDate, ascending: true)],
        animation: .default)
    private var spaces: FetchedResults<SharedSpace>
    
    // State for creating a new space
    @State private var showCreateSheet = false
    
    // State for renaming (Logic)
    @State private var renameSheetVisible = false
    @State private var selectedSpace: SharedSpace? = nil
    @State private var renameText: String = ""
    @State private var renameEmoji: String = "❤️"
    
    // State for deleting
    @State private var confirmDeleteVisible = false
    @State private var spaceToDelete: SharedSpace? = nil

    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(spaces) { space in
                    NavigationLink(destination: DashboardView(currentSpace: space)) {
                        SharedSpaceCard(space: space)
                    }
                    .contextMenu {
                        Button {
                            prepareRename(for: space)
                        } label: {
                            Label("Einstellungen", systemImage: "gear")
                        }
                        
                        Button(role: .destructive) {
                            spaceToDelete = space
                            confirmDeleteVisible = true
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Deine Bereiche")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { showCreateSheet = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateSpaceView()
        }
        // ✅ MOVED CONTENT TO SUBVIEW
        .sheet(isPresented: $renameSheetVisible) {
            RenameSpaceSheet(
                isVisible: $renameSheetVisible,
                renameText: $renameText,
                renameEmoji: $renameEmoji,
                onSave: saveRename
            )
        }
        .alert("Bereich löschen?", isPresented: $confirmDeleteVisible, presenting: spaceToDelete) { space in
            Button("Löschen", role: .destructive) { performDelete(space) }
            Button("Abbrechen", role: .cancel) { spaceToDelete = nil }
        } message: { _ in
            Text("Dieser Vorgang kann nicht rückgängig gemacht werden.")
        }
    }
    
    // MARK: - Logic Helpers
    private func prepareRename(for space: SharedSpace) {
        selectedSpace = space
        renameText = space.title ?? ""
        renameEmoji = space.emoji ?? "❤️"
        renameSheetVisible = true
    }

    private func saveRename() {
        guard let space = selectedSpace else { return }
        space.title = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        space.emoji = renameEmoji
        
        do {
            try viewContext.save()
        } catch {
            print("Fehler: \(error.localizedDescription)")
            viewContext.rollback()
        }
        renameSheetVisible = false
        selectedSpace = nil
    }
    
    private func performDelete(_ space: SharedSpace) {
        viewContext.delete(space)
        try? viewContext.save()
        spaceToDelete = nil
    }
}

// ✅ EXTRACTED SUBVIEW (Solves the complexity error)
struct RenameSpaceSheet: View {
    @Binding var isVisible: Bool
    @Binding var renameText: String
    @Binding var renameEmoji: String
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
                        // ✅ FIXED LABEL ERROR HERE
                        Label("Speichern", systemImage: "checkmark")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}



private struct SharedSpaceCard: View {
    
    @ObservedObject var space: SharedSpace
    
    
    private static let dateFormatter: DateFormatter = {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        fmt.timeStyle = .none
        fmt.locale = Locale.current
        return fmt
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(space.emoji ?? "❤️")
                .font(.system(size: 40))
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(space.title ?? "Unbenannt")
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text(space.joinDate.map { Self.dateFormatter.string(from: $0) } ?? "—")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.secondarySystemBackground)))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.primary.opacity(0.05)))
    }
    
}
