//
//  QuickActionsCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 26.03.26.
//
import SwiftUI


struct QuickActionsCard: View {
    @ObservedObject var space: SharedSpace
    @Binding var isSharing: Bool
    var onShare: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "person.badge.plus",
                    label: "Einladen",
                    color: .green,
                    isLoading: isSharing
                ) {
                    onShare()
                }
                
                QuickActionNavLink(
                    icon: "heart.text.square",
                    label: "Love Note",
                    color: .pink,
                    destination: AnyView(LoveNotesOverviewView(space: space))
                )
                
                QuickActionNavLink(
                    icon: "camera",
                    label: "Memory",
                    color: .purple,
                    destination: AnyView(MemoryOverviewView(space: space))
                )
                
                QuickActionNavLink(
                    icon: "checklist",
                    label: "Liste",
                    color: .blue,
                    destination: AnyView(ListsOverviewView(space: space))
                )
                
            }
            .padding(20)
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(20)
            .padding(.horizontal)
        }
    }
    
    struct QuickActionButton: View {
        let icon: String
        let label: String
        let color: Color
        var isLoading: Bool = false
        var action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .frame(width: 44, height: 44)
                    } else {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(color)
                            .frame(width: 44, height: 44)
                            .background(color.opacity(0.12))
                            .clipShape(Circle())
                    }
                    
                    Text(label)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }
    
    struct QuickActionNavLink: View {
        let icon: String
        let label: String
        let color: Color
        var isLoading: Bool = false
        var destination: AnyView
        
        var body: some View {
            NavigationLink(destination: destination) {
                VStack(spacing: 8) {
                    if isLoading {
                        ProgressView()
                            .frame(width: 44, height: 44)
                    } else {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(color)
                            .frame(width: 44, height: 44)
                            .background(color.opacity(0.12))
                            .clipShape(Circle())
                    }
                    
                    Text(label)
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }
}
