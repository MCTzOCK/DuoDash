//
//  CloudSharingView.swift
//  DuoDash
//
//  Created by Ben Siebert on 22.03.26.
//

import SwiftUI
import CloudKit
import UIKit
import Combine

struct CloudSharingView: UIViewControllerRepresentable {
    // Wir übergeben jetzt den FERTIGEN Share und den Container
    let share: CKShare
    let container: CKContainer
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UICloudSharingController {
        // Wir initialisieren den Controller einfach direkt mit den fertigen Daten
        let controller = UICloudSharingController(share: share, container: container)
        
        controller.availablePermissions = [.allowPublic, .allowReadWrite, .allowPrivate]
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UICloudSharingController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UICloudSharingControllerDelegate {
        func itemTitle(for csc: UICloudSharingController) -> String? {
            return "DuoDash Bereich teilen"
        }
        
        var parent: CloudSharingView
        
        init(_ parent: CloudSharingView) {
            self.parent = parent
        }
        
        func cloudSharingControllerDidSaveShare(_ csc: UICloudSharingController) {
            print("✅ Share erfolgreich gespeichert und gesendet!")
            parent.dismiss()
        }
        
        func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
            print("❌ Fehler beim Speichern: \(error.localizedDescription)")
            parent.dismiss()
        }
        
        func cloudSharingControllerDidStopSharing(_ csc: UICloudSharingController) {
            print("🛑 Sharing wurde beendet.")
            parent.dismiss()
        }
    }
}
