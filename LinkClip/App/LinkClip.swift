//
//  LinkClip.swift
//  LinkClip
//
//  Created by 심관혁 on 2/18/25.
//

import SwiftData
import SwiftUI

@main
struct LinkClip: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    let sharedModelContainer = createSharedModelContainer()

    var body: some Scene {

        WindowGroup {
            HomeView()
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    Task { await AppAttestManager.shared.prepareSession() }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
