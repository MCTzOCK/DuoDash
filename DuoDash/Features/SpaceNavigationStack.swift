//
//  HomeView.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI

struct SpaceNavigationStack: View {
    @ObservedObject public var space: SharedSpace
    
    
    var body: some View {
        TabView {
            Tab {
                DashboardView(currentSpace: space)
            } label: {
                Label("Dashboard", systemImage: "house")
            }
            Tab {
                
            } label: {
                Label("Organisation", systemImage: "checklist")
            }
            Tab {
                
            } label: {
                Label("Dates", systemImage: "wineglass.fill")
            }
            Tab {
                
            } label: {
                Label("Mehr", systemImage: "ellipsis")
            }
        }
        .navigationTitle(space.title ?? "DuoDash")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}
