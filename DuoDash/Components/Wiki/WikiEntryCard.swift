//
//  WikiEntryCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 27.03.26.
//


import SwiftUI

struct WikiEntryCard: View {
    let entry: WikiEntry
    @ObservedObject var storage: WikiStorage
    
    @State private var showingDetail = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        Button {
            showingDetail = true
        } label: {
            cardContent
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("Löschen", systemImage: "trash")
            }
        }
        .alert("Eintrag löschen?", isPresented: $showingDeleteAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Löschen", role: .destructive) {
                withAnimation {
                    storage.deleteEntry(entry)
                }
            }
        } message: {
            Text("Dieser Eintrag wird unwiderruflich gelöscht.")
        }
        .sheet(isPresented: $showingDetail) {
            WikiEntryDetailView(entry: entry, storage: storage)
        }
    }
    
    @ViewBuilder
    private var cardContent: some View {
        switch entry.type {
        case .image:
            imageCard
        case .link:
            linkCard
        case .text:
            textCard
        case .size:
            sizeCard
        }
    }
    
    // MARK: - Bild-Karte
    private var imageCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 120)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.purple.opacity(0.1))
                    .frame(height: 120)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.purple.opacity(0.4))
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                
                HStack {
                    Image(systemName: entry.category.icon)
                        .font(.system(size: 9))
                    Text(entry.category.rawValue)
                        .font(.system(size: 9))
                }
                .foregroundColor(.secondary)
            }
            .padding(12)
        }
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(16)
    }
    
    // MARK: - Link-Karte
    private var linkCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "link")
                    .font(.headline)
                    .foregroundColor(.green)
                    .frame(width: 36, height: 36)
                    .background(Color.green.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            Text(entry.content)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            Spacer(minLength: 0)
            
            HStack {
                Image(systemName: entry.category.icon)
                    .font(.system(size: 9))
                Text(entry.category.rawValue)
                    .font(.system(size: 9))
            }
            .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(minHeight: 140)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(16)
    }
    
    // MARK: - Text-Karte
    private var textCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "note.text")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(width: 36, height: 36)
                    .background(Color.blue.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Spacer()
            }
            
            Text(entry.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            Text(entry.content)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            Spacer(minLength: 0)
            
            HStack {
                Image(systemName: entry.category.icon)
                    .font(.system(size: 9))
                Text(entry.category.rawValue)
                    .font(.system(size: 9))
            }
            .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(minHeight: 140)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(16)
    }
    
    // MARK: - Größen-Karte
    private var sizeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "ruler")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .frame(width: 36, height: 36)
                    .background(Color.orange.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                
                Spacer()
            }
            
            Text(entry.title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(entry.content)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Spacer(minLength: 0)
            
            HStack {
                Image(systemName: entry.category.icon)
                    .font(.system(size: 9))
                Text(entry.category.rawValue)
                    .font(.system(size: 9))
            }
            .foregroundColor(.secondary)
        }
        .padding(14)
        .frame(minHeight: 140)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(16)
    }
}
