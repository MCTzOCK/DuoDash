//
//  OverviewView.swift
//  DuoDash
//
//  Created by Ben Siebert on 23.03.26.
//

import SwiftUI
import CoreData

struct OverviewView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SharedSpace.joinDate, ascending: true)],
        animation: .default)
    private var spaces: FetchedResults<SharedSpace>
    
    @State private var sheetVisible = false
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(spaces) { space in
                    NavigationLink(destination: DashboardView(currentSpace: space)) {
                        
                    }
                }
            }
            .padding()
            .navigationTitle("Deine Bereiche")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        sheetVisible = true
                    }) {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $sheetVisible) {
                        CreateSpaceView()
                    }
                }
            }
        }
    }
}
