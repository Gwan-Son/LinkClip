//
//  SwiftDataContainer.swift
//  LinkClip
//
//  Created by 심관혁 on 3/23/25.
//

import SwiftUI
import SwiftData

class SharedModelContainer {
    static let shared = SharedModelContainer()
    
    let container: ModelContainer
    
    private init() {
        let schema = Schema([LinkItem.self, CategoryItem.self])
        
        let groupID = "group.kr.gwanson.LinkClip"
        
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) else {
            fatalError("App Group 설정에 문제가 있습니다.")
        }
        
        let sharedURL = url.appendingPathComponent("shared.sqlite")
        
        let configuration = ModelConfiguration(
            schema: schema,
            url: sharedURL,
            cloudKitDatabase: .none
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("SwiftData 컨테이너를 생성할 수 없습니다: \(error)")
        }
    }
}

func createSharedModelContainer() -> ModelContainer {
    return SharedModelContainer.shared.container
}
