//
//  LinkClip.swift
//  LinkToMe
//
//  Created by 심관혁 on 2/18/25.
//

import SwiftUI
import SwiftData

@main
struct LinkClip: App {
    
    let sharedModelContainer = createSharedModelContainer()
    
    var body: some Scene {
        
        WindowGroup {
            HomeView()
        }
        .modelContainer(sharedModelContainer)
    }
}
