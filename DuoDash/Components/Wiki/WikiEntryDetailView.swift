//
//  WikiEntryDetailView.swift
//  DuoDash
//
//  Created by Ben Siebert on 27.03.26.
//


import SwiftUI

struct WikiEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State var entry: WikiEntry
    @ObservedObject var storage: WikiStorage
    
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // MARK: Bild (falls vorhanden)
                    if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 300)
                            .clipped()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // MARK: Kategorie Badge
                        HStack {
                            Label(entry.category.rawValue, systemImage: entry.category.icon)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .clipShape(Capsule())
                            
                            Spacer()
                            
                            Label(entry.type.rawValue, systemImage: entry.type.icon)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        // MARK: Titel
                        Text(entry.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        // MARK: Inhalt
                        if !entry.content.isEmpty {
                            if entry.type == .link {
                                Link(destination: URL(string: entry.content) ?? URL(string: "https://apple.com")!) {
                                    HStack {
                                        Image(systemName: "safari.fill")
                                        Text(entry.content)
                                            .lineLimit(1)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemFill))
                                    .cornerRadius(12)
                                }
                            } else if entry.type == .size {
                                HStack {
                                    Text(entry.content)
                                        .font(.system(.largeTitle, design: .rounded))
                                        .fontWeight(.bold)
                                        .foregroundColor(.accentColor)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 30)
                                .background(Color(UIColor.secondarySystemFill))
                                .cornerRadius(16)
                            } else {
                                Text(entry.content)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        // MARK: Meta-Infos
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.secondary)
                                Text("Erstellt: \(formattedDate(entry.createdAt))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: "pencil")
                                    .foregroundColor(.secondary)
                                Text("Bearbeitet: \(formattedDate(entry.updatedAt))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            isEditing = true
                        } label: {
                            Label("Bearbeiten", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            storage.deleteEntry(entry)
                            dismiss()
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $isEditing) {
                EditWikiEntryView(entry: $entry, storage: storage)
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Edit View (vereinfacht)
struct EditWikiEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var entry: WikiEntry
    @ObservedObject var storage: WikiStorage
    
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var category: WikiCategory = .other
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Kategorie")) {
                    Picker("Kategorie", selection: $category) {
                        ForEach(WikiCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                }
                
                Section(header: Text("Titel")) {
                    TextField("Titel", text: $title)
                }
                
                Section(header: Text("Inhalt")) {
                    if entry.type == .text {
                        TextEditor(text: $content)
                            .frame(minHeight: 100)
                    } else {
                        TextField("Inhalt", text: $content)
                    }
                }
            }
            .navigationTitle("Bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Speichern") {
                        entry.title = title
                        entry.content = content
                        entry.category = category
                        storage.updateEntry(entry)
                        dismiss()
                    }
                    .bold()
                }
            }
            .onAppear {
                title = entry.title
                content = entry.content
                category = entry.category
            }
        }
    }
}
