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
    
    let sharedModelContainer = createSharedModelContainer()
    
    var body: some Scene {
        
        WindowGroup {
            viewController()
//            ShareView()
        }
        .modelContainer(sharedModelContainer)
        //        .modelContainer(for: [LinkItem.self, Tag.self])
    }
}
