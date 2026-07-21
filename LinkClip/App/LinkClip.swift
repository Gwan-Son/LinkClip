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
    @AppStorage(
        UserDefaults.Keys.appearance,
        store: UserDefaults.shared
    ) private var appearance = AppAppearance.system

    let sharedModelContainer = createSharedModelContainer()

    init() {
        let defaults = UserDefaults.shared
        if defaults.object(forKey: UserDefaults.Keys.onboardingVersion) == nil,
           defaults.string(forKey: UserDefaults.Keys.summaryInstallationID) != nil {
            defaults.set(2, forKey: UserDefaults.Keys.onboardingVersion)
        }
    }

    var body: some Scene {

        WindowGroup {
            OnboardingGateView()
                .preferredColorScheme(appearance.colorScheme)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    Task { await AppAttestManager.shared.prepareSession() }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
