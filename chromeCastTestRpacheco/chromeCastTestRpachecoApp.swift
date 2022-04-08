//
//  chromeCastTestRpachecoApp.swift
//  chromeCastTestRpacheco
//
//  Created by Richard Pacheco on 4/5/22.
//

import SwiftUI
import GoogleCast

@main
struct chromeCastTestRpachecoApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            NavigationView {
                CustomPlayerView()
                    .navigationTitle("CustomVideoPlayer")
                    .navigationBarItems(trailing: CastButton())
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, GCKLoggerDelegate {
    
    func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        CastManager.shared.initialise()
        return true
    }
}
