//
//  SettingsInfoRow.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI

public struct SettingsInfoRow: View {
    public let icon: String
    public let color: Color
    public let title: LocalizedStringKey
    public let value: String
    
    @Environment(\.colorScheme) var colorScheme
    
    public init(icon: String, color: Color, title: LocalizedStringKey, value: String) {
        self.icon = icon
        self.color = color
        self.title = title
        self.value = value
    }
    
    public var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(color)
                .cornerRadius(6)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(
                    colorScheme == .dark ? .white : .black
                )
            
            Spacer()
            value != "no-disclosure" ? Image(systemName: "chevron.right")
                .foregroundStyle(.gray.opacity(0.7))
                .font(.system(size: 14, weight: .semibold)) : nil
            
        }
    }
}
