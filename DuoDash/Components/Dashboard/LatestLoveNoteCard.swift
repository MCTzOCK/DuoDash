//
//  LatestLoveNoteCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//
import SwiftUI

struct LatestLoveNoteCard: View {
    @ObservedObject var space: SharedSpace
    
    private var latestNote: LoveNote? {
        let myID = SharedDefaults.myUserID
        let all = (space.loveNotes?.allObjects as? [LoveNote]) ?? []
        return all
            .filter { $0.authorId != myID }
            .sorted { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
            .first
    }
    
    var body: some View {
        if let note = latestNote {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "heart.text.square.fill")
                        .foregroundColor(.pink)
                        .font(.headline)
                    Text("Love Note von deinem Partner")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                Text("\"\(note.message ?? "")\"")
                    .font(.system(.body, design: .serif))
                    .italic()
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                
                if let date = note.createdAt {
                    Text(relativeDate(date))
                        .font(.caption)
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [Color.pink.opacity(0.08), Color.pink.opacity(0.03)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.pink.opacity(0.15), lineWidth: 1)
            )
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
    
    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
