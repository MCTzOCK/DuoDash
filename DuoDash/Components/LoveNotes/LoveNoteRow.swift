//
//  LoveNoteRow.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//
import SwiftUI


struct LoveNoteRow: View {
    @ObservedObject var note: LoveNote
    let isMine: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isMine ? "arrow.up.heart.fill" : "arrow.down.heart.fill")
                .foregroundColor(isMine ? .blue : .pink)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(note.message ?? "")
                    .font(.body)
                    .lineLimit(3)
                
                if let date = note.createdAt {
                    Text(relativeDate(date))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func relativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
