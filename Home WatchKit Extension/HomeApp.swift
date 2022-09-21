//
//  HomeApp.swift
//  Home WatchKit Extension
//
//  Created by Artur Hellmann on 20.09.22.
//

import SwiftUI

@main
struct HomeApp: App {

    @WKExtensionDelegateAdaptor private var extensionDelegate: ExtensionDelegate

    @SceneBuilder var body: some Scene {
        WindowGroup {
            ContentView()
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
