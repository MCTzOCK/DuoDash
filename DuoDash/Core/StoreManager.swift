//
//  StoreManager.swift
//  DuoDash
//
//  Created by Ben Siebert on 27.03.26.
//

import StoreKit
import SwiftUI
import Combine

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedSuccess: Bool = false
    
    // Die IDs aus deiner .storekit Datei
    private let productIDs = ["tip.coffee", "tip.pizza", "tip.date"]
    
    init() {
        Task {
            await loadProducts()
        }
    }
    
    func loadProducts() async {
        do {
            // Holt die Produkte sicher von Apple (oder lokal aus der .storekit Datei)
            let fetchedProducts = try await Product.products(for: productIDs)
            // Sortiert nach Preis (aufsteigend)
            self.products = fetchedProducts.sorted(by: { $0.price < $1.price })
        } catch {
            print("Fehler beim Laden der In-App-Käufe: \(error)")
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Kauf war erfolgreich!
                let transaction = try verification.payloadValue
                
                // Transaktion als abgeschlossen markieren
                await transaction.finish()
                
                // UI aktualisieren (z.B. für "Danke"-Nachricht)
                self.purchasedSuccess = true
                
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Kauf fehlgeschlagen: \(error)")
        }
    }
}
