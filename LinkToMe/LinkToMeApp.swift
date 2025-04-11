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
    
    let sharedModelContainer = createSharedModelContainer()
    
    var body: some Scene {
        
        WindowGroup {
            HomeView()
        }
        .modelContainer(sharedModelContainer)
    }
}
