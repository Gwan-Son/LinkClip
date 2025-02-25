//
//  LinkToMeApp.swift
//  LinkToMe
//
//  Created by 심관혁 on 2/18/25.
//

import SwiftUI
import SwiftData

@main
struct LinkToMeApp: App {
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            viewController()
        }
        .modelContainer(for: [LinkItem.self, Tag.self])
    }
}
