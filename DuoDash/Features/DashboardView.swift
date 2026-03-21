//
//  DashboardView.swift
//  DuoDash
//
//  Created by Ben Siebert on 21.03.26.
//

import SwiftUI

struct DashboardView: View {
    // Wir übergeben den aktiven Space aus der ContentView hierher
    @ObservedObject var currentSpace: SharedSpace
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                 Text("Unser Bereich")
                    .font(.largeTitle)
                    .bold()
                
                Spacer()
                
                Button(action: {
                    print("Teilen-Flow wird gestartet...")
                }) {
                    Label("Partner einladen", systemImage: "person.badge.plus")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
            .navigationTitle("Dashboard")
        }
    }
}
