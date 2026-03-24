//
//  CreateSpaceView.swift
//  DuoDash
//
//  Created by Ben Siebert on 23.03.26.
//

import SwiftUI
import SwiftEmojiPicker

struct CreateSpaceView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var title: String = ""
    @State private var emoji: String = "❤️"
    @State private var showPicker: Bool = false
    
    var body: some View {
        VStack {
            
            Spacer()
            
            Image(systemName: "plus.rectangle.fill.on.folder.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Neuer Bereich")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Erstelle einen neuen Bereich, um deinen Partner einzuladen, oder öffne einen Einladungslink aus iMessage, um einem Bereich beizutreten.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
            HStack {
                Button(emoji) {
                    showPicker = true
                }
                .emojiPicker(isPresented: $showPicker, selectedEmoji: $emoji)
                .padding(16)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                TextField("Bereichsname", text: $title)
                    .padding(16)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            Button {
                CoreDataManager.shared.createSharedSpace(title: title, emoji: emoji)
                dismiss()
            } label: {
                Text("Neuen Bereich erstellen")
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
    }
    
    func saveItem() {
        
    }
}

#Preview {
    CreateSpaceView()
}
