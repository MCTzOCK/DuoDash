//
//  LoveNotesOverviewView.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//


import SwiftUI
import CoreData
import WidgetKit


// MARK: - ===========================================
// MARK: - 1. LOVE NOTES ÜBERSICHT
// MARK: - ===========================================

struct LoveNotesOverviewView: View {
    
    @ObservedObject var space: SharedSpace
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest var notes: FetchedResults<LoveNote>
    
    @State private var showingCreateSheet = false
    
    private var myUserID: String { SharedDefaults.myUserID }
    
    init(space: SharedSpace) {
        self.space = space
        _notes = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \LoveNote.createdAt, ascending: false)],
            predicate: NSPredicate(format: "space == %@", space)
        )
    }
    
    /// Nachrichten, die der PARTNER geschrieben hat (für mich)
    private var notesFromPartner: [LoveNote] {
        notes.filter { $0.authorId != myUserID }
    }
    
    /// Nachrichten, die ICH geschrieben habe (für den Partner)
    private var notesFromMe: [LoveNote] {
        notes.filter { $0.authorId == myUserID }
    }
    
    var body: some View {
        List {
            // MARK: Aktuelle Widget-Nachricht
            if let latestFromPartner = notesFromPartner.first {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.pink)
                        
                        Text("Aktuelle Nachricht auf deinem Widget:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\"\(latestFromPartner.message ?? "")\"")
                            .font(.title3)
                            .fontWeight(.medium)
                            .multilineTextAlignment(.center)
                            .italic()
                        
                        if let date = latestFromPartner.createdAt {
                            Text(formattedDate(date))
                                .font(.caption2)
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .listRowBackground(Color.pink.opacity(0.08))
            }
            
            // MARK: Nachricht schreiben
            Section {
                Button {
                    showingCreateSheet = true
                } label: {
                    Label("Neue Love Note schreiben", systemImage: "square.and.pencil")
                        .font(.headline)
                        .foregroundColor(.accentColor)
                }
            }
            
            // MARK: Meine gesendeten Nachrichten
            if !notesFromMe.isEmpty {
                Section(header: Text("Von dir gesendet")) {
                    ForEach(notesFromMe) { note in
                        LoveNoteRow(note: note, isMine: true)
                    }
                    .onDelete { offsets in
                        deleteNotes(from: notesFromMe, at: offsets)
                    }
                }
            }
            
            // MARK: Vom Partner erhaltene Nachrichten
            if !notesFromPartner.isEmpty {
                Section(header: Text("Von deinem Partner")) {
                    ForEach(notesFromPartner) { note in
                        LoveNoteRow(note: note, isMine: false)
                    }
                }
            }
            
            // MARK: Empty State
            if notes.isEmpty {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "heart.text.square")
                            .font(.system(size: 44))
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                        
                        Text("Noch keine Love Notes")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Schreibe deinem Partner eine kleine Nachricht, die direkt auf seinem Homescreen erscheint!")
                            .font(.subheadline)
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Love Notes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateLoveNoteView(space: space)
        }
        // Wenn sich die Notes ändern (z.B. neue vom Partner), Widget aktualisieren
        .onChange(of: notes.count) { _ in
            //updateWidgetWithLatestPartnerNote()
            CoreDataManager.shared.syncDataToWidget()
        }
        .onAppear {
            //updateWidgetWithLatestPartnerNote()
            CoreDataManager.shared.syncDataToWidget()
        }
    }
    
    
    private func deleteNotes(from source: [LoveNote], at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                viewContext.delete(source[index])
            }
            try? viewContext.save()
            WidgetCenter.shared.reloadAllTimelines()
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
