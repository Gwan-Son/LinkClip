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

    let sharedModelContainer = createSharedModelContainer()

    var body: some Scene {

        WindowGroup {
            HomeView()
        }
        .modelContainer(sharedModelContainer)
    }
}
