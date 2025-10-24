//
//  SwiftDataContainer.swift
//  LinkClip
//
//  Created by 심관혁 on 3/23/25.
//

import SwiftData
import SwiftUI

class SharedModelContainer {
    static let shared = SharedModelContainer()

    let container: ModelContainer

    private init() {
        let schema = Schema([LinkItem.self, CategoryItem.self])

        let groupID = "group.kr.gwanson.LinkClip"

        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)
        else {
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

// 테스트/프리뷰용 에페메랄 컨테이너 팩토리
// 메모리 전용 컨테이너(In-Memory, 비영구) 생성 함수
func createInMemoryModelContainer() -> ModelContainer {
    let schema = Schema([LinkItem.self, CategoryItem.self])
    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true,
        cloudKitDatabase: .none
    )
    do {
        return try ModelContainer(for: schema, configurations: [configuration])
    } catch {
        fatalError("메모리 전용 SwiftData 컨테이너 생성 실패: \(error)")
    }
}
