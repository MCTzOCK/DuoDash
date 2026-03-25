//
//  SymbolPickerGrid.swift
//  DuoDash
//
//  Created by Ben Siebert on 25.03.26.
//
import SwiftUI

struct SymbolPickerGrid: View {
    
    @Binding var selectedSymbol: String
    
    let symbols: [(name: String, symbol: String)] = [
        ("Einkauf", "cart.fill"),
        ("To-Do", "checklist"),
        ("Packliste", "suitcase.fill"),
        ("Geschenke", "gift.fill"),
        ("Rezepte", "fork.knife"),
        ("Filme", "film"),
        ("Bücher", "book.fill"),
        ("Fitness", "figure.run"),
        ("Haus", "house.fill"),
        ("Herz", "heart.fill"),
        ("Stern", "star.fill"),
        ("Ideen", "lightbulb.fill"),
    ]
    
    let columns = Array(repeating: GridItem(.flexible()), count: 6)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(symbols, id: \.symbol) { item in
                // Wir benutzen KEIN Button, sondern ein reines Image mit onTapGesture
                Image(systemName: item.symbol)
                    .font(.title3)
                    .foregroundColor(selectedSymbol == item.symbol ? .white : .accentColor)
                    .frame(width: 44, height: 44)
                    .background(
                        selectedSymbol == item.symbol
                        ? Color.accentColor
                        : Color.accentColor.opacity(0.15)
                    )
                    .clipShape(Circle())
                    .contentShape(Circle()) // Macht den gesamten Kreis tippbar
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selectedSymbol = item.symbol
                        }
                    }
            }
        }
        .padding(.vertical, 8)
    }
}
