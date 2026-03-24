//
//  SpaceMoreView.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI

struct SpaceMoreView: View {
    
    @ObservedObject var space: SharedSpace
    
    var openSettings: () -> Void
    
    var body: some View {
        List {
            Section("Funktionen") {
                NavigationLink(destination: CountdownOverviewView(space: space)) {
                    SettingsInfoRow(icon: "hourglass", color: .orange, title: "Countdowns", value: "no-disclosure")
                }
            }
            Section("Einstellungen") {
                Button {
                    openSettings()
                } label: {
                    SettingsInfoRow(icon: "gear", color: .blue, title: "Bereich verwalten", value: "")
                }
            }
        }
    }
}
