//
//  SwiftDataContainer.swift
//  LinkClip
//
//  Created by 심관혁 on 3/23/25.
//

import SwiftData
import SwiftUI

// MARK: - 스키마 버전 관리
enum LinkClipSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [LinkItemV1.self, CategoryItemV1.self]
    }

    // V1 모델들 (기존 모델)
    @Model
    final class CategoryItemV1 {
        var id: UUID
        var name: String
        var icon: String
        var createdDate: Date?

        // 호환성을 위해 유지 (사용하지 않음)
        var parentCategory: CategoryItemV1?

        @Relationship(deleteRule: .nullify, inverse: \LinkItemV1.category)
        var links: [LinkItemV1]?

        init(name: String, icon: String) {
            self.id = UUID()
            self.name = name
            self.icon = icon
            self.createdDate = Date()
            self.parentCategory = nil
            self.links = []
        }
    }

    @Model
    final class LinkItemV1 {
        var id: UUID
        @Attribute(.unique) var url: String
        var title: String
        var personalMemo: String?
        var savedDate: Date
        var category: CategoryItemV1?

        // 메타데이터 속성들
        var metaDescription: String?
        var imageURL: String?
        var siteName: String?
        var faviconURL: String?
        var isMetadataLoaded: Bool?
        var metadataLoadDate: Date?

        init(
            url: String, title: String, personalMemo: String? = nil, category: CategoryItemV1? = nil,
            metaDescription: String? = nil, imageURL: String? = nil, siteName: String? = nil,
            faviconURL: String? = nil, isMetadataLoaded: Bool? = false, metadataLoadDate: Date? = nil
        ) {
            self.id = UUID()
            self.url = url
            self.title = title
            self.personalMemo = personalMemo
            self.savedDate = Date()
            self.category = category
            self.metaDescription = metaDescription
            self.imageURL = imageURL
            self.siteName = siteName
            self.faviconURL = faviconURL
            self.isMetadataLoaded = isMetadataLoaded
            self.metadataLoadDate = metadataLoadDate
        }
    }
}

enum LinkClipSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [LinkItem.self, CategoryItem.self]
    }
}

// MARK: - 마이그레이션 계획
enum LinkClipMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [LinkClipSchemaV1.self, LinkClipSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: LinkClipSchemaV1.self,
        toVersion: LinkClipSchemaV2.self
    )
}

class SharedModelContainer {
    static let shared = SharedModelContainer()

    let container: ModelContainer

    private init() {
        let schema = Schema(versionedSchema: LinkClipSchemaV2.self)

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

// MARK: - 공유 UserDefaults (ShareExtension 통신용)
extension UserDefaults {
    static let shared = UserDefaults(suiteName: "group.kr.gwanson.LinkClip")!

    enum Keys {
        static let dataChanged = "dataChanged"
        static let lastChangeTimestamp = "lastChangeTimestamp"
    }

    // ShareExtension에서 데이터 변경 알림
    func notifyDataChanged() {
        set(true, forKey: Keys.dataChanged)
        set(Date().timeIntervalSince1970, forKey: Keys.lastChangeTimestamp)
        synchronize()
    }

    // 메인 앱에서 변경 확인 및 초기화
    func consumeDataChange() -> Bool {
        let hasChanged = bool(forKey: Keys.dataChanged)
        if hasChanged {
            set(false, forKey: Keys.dataChanged)
            removeObject(forKey: Keys.lastChangeTimestamp)
            synchronize()
        }
        return hasChanged
    }
}

// MARK: - 마이그레이션 지원을 위한 기존 모델 액세스
class SharedModelContainerLegacy {
    static let shared = SharedModelContainerLegacy()

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

// 테스트/프리뷰용 에페메랄 컨테이너 팩토리
// 메모리 전용 컨테이너(In-Memory, 비영구) 생성 함수
func createInMemoryModelContainer() -> ModelContainer {
    let schema = Schema(versionedSchema: LinkClipSchemaV2.self)
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
