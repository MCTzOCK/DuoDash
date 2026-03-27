//
//  AuthenticateView.swift
//  DuoDash
//
//  Created by Ben Siebert on 27.03.26.
//
import SwiftUI
import LocalAuthentication

struct NeedsFaceIDModifier: ViewModifier {
    // Speichert den Authentifizierungs-Status für den View, an den der Modifier gehängt wird
    @State private var isAuthenticated = false
    
    func body(content: Content) -> some View {
        Group {
            if isAuthenticated {
                // Wenn authentifiziert, zeige den eigentlichen View
                content
            } else {
                // Wenn nicht, blockiere die Sicht mit dem AuthenticateView
                AuthenticateView(authenticated: $isAuthenticated)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(UIColor.systemBackground))
                // Optionale Animation für einen weicheren Übergang nach erfolgreichem Login
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: isAuthenticated)
    }
}

// MARK: - 2. View Extension
extension View {
    /// Schützt den View mit einer Face-ID / Touch-ID Abfrage.
    /// Der eigentliche Inhalt wird erst nach erfolgreicher Authentifizierung gerendert.
    func needsFaceID() -> some View {
        self.modifier(NeedsFaceIDModifier())
    }
}

// MARK: - 3. Dein angepasster AuthenticateView
struct AuthenticateView: View {
    
    // Geändert: Statt @State nutzen wir @Binding, damit der Modifier weiß, wann er umschalten muss.
    @Binding var authenticated: Bool
    
    var body: some View {
        
        VStack(spacing: 12) {
            Image(systemName: "lock.shield")
                .font(.system(size: 50))
                .foregroundColor(Color(UIColor.tertiaryLabel))
            
            Text("Anmeldung erforderlich")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Bitte melde dich mit Face-ID an, um deine Daten zu schützen.")
                .font(.subheadline)
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                authenticate()
            } label: {
                Label("Face-ID", systemImage: "faceid")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.top, 8)
        }
        .padding(.vertical, 60)
        .onAppear {
            authenticate()
        }
    }
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We need to unlock your data."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                // WICHTIG: UI-Updates müssen auf dem Main-Thread ausgeführt werden!
                DispatchQueue.main.async {
                    if success {
                        self.authenticated = true
                    } else {
                        // Fehlgeschlagen (Nutzer hat abgebrochen etc.)
                    }
                }
            }
        } else {
            // no biometrics
            // Hier könntest du z.B. einen Fallback auf Passcode-Eingabe anbieten
        }
    }
}
