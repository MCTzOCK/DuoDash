//
//  TipJarView.swift
//  DuoDash
//
//  Created by Ben Siebert on 27.03.26.
//


import SwiftUI
import StoreKit

struct TipJarView: View {
    @StateObject private var store = StoreManager()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    
                    // MARK: Header
                    VStack(spacing: 12) {
                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.accent)
                        
                        Text("Unterstütze DuoDash")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("DuoDash wird von einem einzelnen Entwickler (mir!) gebaut. Wenn euch die App gefällt und ihr meine Arbeit unterstützen wollt, freue ich mich über eine kleine Spende. ❤️")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // MARK: Erfolgs-Nachricht
                    if store.purchasedSuccess {
                        VStack {
                            Text("🎉 VIELEN DANK! 🎉")
                                .font(.headline)
                                .foregroundColor(.green)
                            Text("Du bist der Wahnsinn!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    
                    // MARK: Die Produkte (Laden automatisch)
                    if store.products.isEmpty {
                        ProgressView("Lade Preise...")
                    } else {
                        VStack(spacing: 16) {
                            ForEach(store.products) { product in
                                Button {
                                    Task {
                                        await store.purchase(product)
                                    }
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(product.displayName)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text(product.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(product.displayPrice)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(Color.accentColor)
                                            .clipShape(Capsule())
                                    }
                                    .padding()
                                    .background(Color(UIColor.secondarySystemFill))
                                    .cornerRadius(16)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Kaffeekasse")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
}
