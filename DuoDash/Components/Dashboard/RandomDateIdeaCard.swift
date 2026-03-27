//
//  RandomDateIdeaCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//
import SwiftUI


struct RandomDateIdeaCard: View {
    @ObservedObject var space: SharedSpace
    @State private var currentIdea: DateIdea?
    
    private var openIdeas: [DateIdea] {
        let all = (space.dateIdeas?.allObjects as? [DateIdea]) ?? []
        return all.filter { !$0.isDone }
    }
    
    var body: some View {
        if !openIdeas.isEmpty {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.accent)
                        .font(.headline)
                    Text("Date-Vorschlag")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            currentIdea = openIdeas.randomElement()
                        }
                    } label: {
                        Image(systemName: "shuffle")
                            .font(.subheadline)
                            .foregroundColor(.accent)
                    }
                }
                
                if let idea = currentIdea {
                    HStack(spacing: 14) {
                        // Bild oder Placeholder
                        if let imgData = idea.imageData, let uiImage = UIImage(data: imgData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else {
                            Image(systemName: "heart.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.accent.opacity(0.4))
                                .frame(width: 56, height: 56)
                                .background(Color.accent.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(idea.title ?? "Date-Idee")
                                .font(.headline)
                            
                            if idea.priceLevel > 0 {
                                Text(String(repeating: "€", count: Int(idea.priceLevel)))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(20)
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(20)
            .padding(.horizontal)
            .onAppear {
                currentIdea = openIdeas.randomElement()
            }
        }
    }
}
