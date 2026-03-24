//
//  OnboardingView.swift
//  DuoDash
//
//  Created by Ben Siebert on 21.03.26.
//
import SwiftUI

struct OnboardingView: View {
    
    @State private var showSheet = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "person.2.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("Willkommen bei DuoDash")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Erstelle einen neuen Bereich, um deinen Partner einzuladen, oder öffne einen Einladungslink aus iMessage, um einem Bereich beizutreten.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 30)
            
            Spacer()
            
            Button(action: {
                showSheet = true
            }) {
                Text("Neuen Bereich erstellen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accent)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 50)
            .sheet(isPresented: $showSheet) {
                CreateSpaceView()
            }
        }
    }
}
