//
//  CreateLoveNoteView.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//
import SwiftUI
import CoreData
import WidgetKit
import StoreKit

struct CreateLoveNoteView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.requestReview) var requestReview

    @State private var message: String = ""
    @ObservedObject var space: SharedSpace
    
    // Vorschläge für schnelle Inspiration
    private let quickNotes = [
        "Ich liebe dich! ❤️",
        "Du bist mein Lieblingsmensch 🥰",
        "Ich denke an dich! 💭",
        "Ich bin so froh, dass es dich gibt 🌟",
        "Heute Abend nur wir zwei? 🍷",
        "Du machst mich glücklich 😊",
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            
            Form {
                // MARK: Header
                Section {
                    VStack {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.pink)
                        
                        Text("Neue Love Note")
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                        
                        Text("Schreibe eine kurze Nachricht, die auf dem Homescreen deines Partners erscheint.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden, edges: .all)
                
                // MARK: Nachricht
                Section(header: Text("Deine Nachricht")) {
                    TextField("Was möchtest du sagen?", text: $message, axis: .vertical)
                        .lineLimit(3...6)
                        .font(.body)
                    
                    // Zeichenzähler
                    HStack {
                        Spacer()
                        Text("\(message.count) / 120")
                            .font(.caption)
                            .foregroundColor(message.count > 120 ? .red : .secondary)
                    }
                }
                
                // MARK: Schnelle Vorschläge
                Section(header: Text("Oder wähle eine Vorlage")) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(quickNotes, id: \.self) { note in
                                Text(note)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(Color.pink.opacity(0.12))
                                    .foregroundColor(.pink)
                                    .clipShape(Capsule())
                                    .onTapGesture {
                                        message = note
                                    }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
            }
            
            // MARK: Buttons
            VStack(spacing: 16) {
                Button {
                    saveNote()
                } label: {
                    Text("Love Note senden 💌")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(message.isEmpty || message.count > 120 ? Color.pink.opacity(0.4) : Color.pink)
                        .cornerRadius(12)
                }
                .disabled(message.isEmpty || message.count > 120)
                
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
    }
    
    private func saveNote() {
        let newNote = LoveNote(context: viewContext)
        newNote.id = UUID()
        newNote.message = message
        newNote.createdAt = Date()
        newNote.authorId = SharedDefaults.myUserID // Meine ID als Autor
        newNote.space = space
        
        do {
            try viewContext.save()
            
            // Widget des Partners wird beim nächsten Sync aktualisiert
            // Für das EIGENE Widget (falls man es selbst auch hat) sofort aktualisieren
            WidgetCenter.shared.reloadAllTimelines()
            
            dismiss()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                requestReview()
            }
        } catch {
            print("Fehler beim Speichern: \(error.localizedDescription)")
        }
    }
}
