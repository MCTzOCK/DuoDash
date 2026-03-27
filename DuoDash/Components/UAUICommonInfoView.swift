//
//  UAUICommonInfoView.swift
//  DuoDash
//
//  Created by Ben Siebert on 27.03.26.
//



import SwiftUI

public struct UAUICommonInfoView<Content: View>: View {
    
    public let title: String
    public let logoName: String
    public let version: String
    public let libraries: [OpenSourceLibrary]
    public let content: Content
    
    public init(
        title: String,
        logoName: String,
        version: String,
        libraries: [OpenSourceLibrary],
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.logoName = logoName
        self.version = version
        self.libraries = libraries
        self.content = content()
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(logoName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .shadow(radius: 5)
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)))
                            Text(title)
                                .font(.title)
                                .fontWeight(.bold)
                            Text(version)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                Section {
                    Link(destination: URL(string: "https://apps.apple.com/us/developer/ben-siebert/id1703019142")!) {
                        SettingsInfoRow(icon: "star.fill", color: .yellow, title: "Mehr Apps von mir :)", value: "")
                    }
                }
                
                content
                    
                Section("Legal") {
                    Link(destination: URL(string: "https://mctzock.github.io/ios-apps-pages/legal/notice")!) {
                        SettingsInfoRow(icon: "doc.text.fill", color: .blue, title: "Impressum", value: "")
                    }
                    Link(destination: URL(string: "https://mctzock.github.io/ios-apps-pages/legal/privacy")!) {
                        SettingsInfoRow(icon: "doc.text.fill", color: .green, title: "Datenschutzerklärung", value: "")
                    }
                    libraries.count > 0 ? (
                        NavigationLink {
                            LicenseViewer(libraries: libraries)
                        } label: {
                            SettingsInfoRow(icon: "books.vertical.fill", color: .indigo, title: "Open Source Lizenzen", value: "no-disclosure")
                        }
                    ) : nil
                }
            }
        }
    }
}
