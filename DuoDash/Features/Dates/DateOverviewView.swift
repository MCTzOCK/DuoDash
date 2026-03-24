//
//  DateOverviewView.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI
import CoreData

struct DateOverviewView: View {
    
    @ObservedObject var space: SharedSpace
    
    @State private var showCreateSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                if space.dateIdeas?.allObjects.count == 0 {
                    ContentUnavailableView {
                        Label("Keine Dates", systemImage: "wineglass")
                    } description: {
                        VStack(spacing: 20) {
                            Text("Es wurden keine Date-Ideen erstellt. Tippe auf das Plus-Symbol, um euer erstes Date zu planen!")
                            Button() {
                                showCreateSheet = true
                            } label: {
                                Label("Date erstellen", systemImage: "plus")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.accent)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Dates")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    showCreateSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            
        }
    }
}
