//
//  AppDelegate.swift
//  DuoDash
//
//  Created by Ben Siebert on 22.03.26.
//

import UIKit
import CloudKit
import SwiftUI

// 1. Der SceneDelegate (Hier landen SwiftUI CloudKit-Links wirklich!)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    func windowScene(_ windowScene: UIWindowScene, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        print("🔗 SceneDelegate: CloudKit-Link wurde geklickt!")
        CoreDataManager.shared.acceptShare(metadata: cloudKitShareMetadata)
    }
}

// 2. Der AppDelegate meldet den SceneDelegate bei iOS an
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        // Hier sagen wir Apple: "Bitte nutze unseren eigenen SceneDelegate"
        config.delegateClass = SceneDelegate.self
        return config
    }
}
