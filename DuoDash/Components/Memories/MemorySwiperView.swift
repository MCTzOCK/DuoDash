//
//  MemorySwiperView.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//
import SwiftUI
import CoreData
import PhotosUI


struct MemorySwiperView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    let memories: [Memory]
    @State private var shuffledMemories: [Memory] = []
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Hintergrund
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // MARK: Header
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Fortschrittsanzeige
                    Text("\(currentIndex + 1) / \(shuffledMemories.count)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    // Shuffle-Button
                    Button {
                        reshuffleMemories()
                    } label: {
                        Image(systemName: "shuffle")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding()
                
                Spacer()
                
                // MARK: Die Swipe-Karte
                if !shuffledMemories.isEmpty {
                    let memory = shuffledMemories[currentIndex]
                    
                    SwiperCard(memory: memory)
                        .offset(x: dragOffset.width)
                        .rotationEffect(.degrees(Double(dragOffset.width) / 30))
                        .opacity(1.0 - abs(Double(dragOffset.width)) / 400)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    dragOffset = gesture.translation
                                }
                                .onEnded { gesture in
                                    if abs(gesture.translation.width) > 120 {
                                        // Swipe war stark genug -> nächste Karte
                                        withAnimation(.easeOut(duration: 0.3)) {
                                            dragOffset = CGSize(
                                                width: gesture.translation.width > 0 ? 500 : -500,
                                                height: 0
                                            )
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            goToNext()
                                            dragOffset = .zero
                                        }
                                    } else {
                                        // Zurückschnappen
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            dragOffset = .zero
                                        }
                                    }
                                }
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: dragOffset)
                    
                } else {
                    Text("Keine Erinnerungen vorhanden")
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                // MARK: Navigations-Buttons unten
                if !shuffledMemories.isEmpty {
                    HStack(spacing: 40) {
                        // Zurück
                        Button {
                            goToPrevious()
                        } label: {
                            Image(systemName: "arrow.left.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(currentIndex == 0 ? 0.2 : 0.7))
                        }
                        .disabled(currentIndex == 0)
                        
                        // Weiter
                        Button {
                            withAnimation(.easeOut(duration: 0.3)) {
                                dragOffset = CGSize(width: -500, height: 0)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                goToNext()
                                dragOffset = .zero
                            }
                        } label: {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .onAppear {
            shuffledMemories = memories.shuffled()
        }
    }
    
    private func goToNext() {
        if currentIndex < shuffledMemories.count - 1 {
            currentIndex += 1
        } else {
            // Am Ende angekommen -> Reshuffle und von vorne
            shuffledMemories.shuffle()
            currentIndex = 0
        }
    }
    
    private func goToPrevious() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
    
    private func reshuffleMemories() {
        withAnimation {
            shuffledMemories.shuffle()
            currentIndex = 0
            dragOffset = .zero
        }
    }
}
