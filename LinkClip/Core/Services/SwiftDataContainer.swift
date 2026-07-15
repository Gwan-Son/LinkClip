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
        static let favoriteLinkIDs = "favoriteLinkIDs"
        static let categoryOrder = "categoryOrder"
        static let summaryAPIBaseURL = "summaryAPIBaseURL"
        static let summaryInstallationID = "summaryInstallationID"
        static let summaryLinkIDs = "summaryLinkIDs"
    }

    var favoriteLinkIDs: Set<UUID> {
        get { Set(stringArray(forKey: Keys.favoriteLinkIDs)?.compactMap(UUID.init) ?? []) }
        set { set(newValue.map(\.uuidString), forKey: Keys.favoriteLinkIDs) }
    }

    var categoryOrder: [UUID] {
        get { stringArray(forKey: Keys.categoryOrder)?.compactMap(UUID.init) ?? [] }
        set { set(newValue.map(\.uuidString), forKey: Keys.categoryOrder) }
    }

    var summaryInstallationID: String {
        if let value = string(forKey: Keys.summaryInstallationID) { return value }
        let value = UUID().uuidString
        set(value, forKey: Keys.summaryInstallationID)
        return value
    }

    func summaryRecord(for linkID: UUID) -> SummaryRecord? {
        data(forKey: "summary.\(linkID.uuidString)")
            .flatMap { try? JSONDecoder().decode(SummaryRecord.self, from: $0) }
    }

    func saveSummaryRecord(_ record: SummaryRecord) {
        guard let data = try? JSONEncoder().encode(record) else { return }
        set(data, forKey: "summary.\(record.linkID.uuidString)")
        var ids = Set(stringArray(forKey: Keys.summaryLinkIDs) ?? [])
        ids.insert(record.linkID.uuidString)
        set(Array(ids), forKey: Keys.summaryLinkIDs)
    }

    func removeSummaryRecord(for linkID: UUID) {
        removeObject(forKey: "summary.\(linkID.uuidString)")
        var ids = Set(stringArray(forKey: Keys.summaryLinkIDs) ?? [])
        ids.remove(linkID.uuidString)
        set(Array(ids), forKey: Keys.summaryLinkIDs)
    }

    func removeAllSummaryRecords() {
        for id in stringArray(forKey: Keys.summaryLinkIDs) ?? [] {
            removeObject(forKey: "summary.\(id)")
        }
        removeObject(forKey: Keys.summaryLinkIDs)
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

enum SummaryStatus: String, Codable {
    case pending
    case queued
    case processing
    case completed
    case failed
}

struct SummaryRecord: Codable, Equatable, Identifiable {
    var id: UUID { linkID }
    let linkID: UUID
    var jobID: String?
    var status: SummaryStatus
    var summary: String?
    var error: String?
    var updatedAt: Date
}

enum SummaryAPIError: LocalizedError {
    case invalidServerURL
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidServerURL: return "유효한 HTTPS 서버 주소가 아닙니다."
        case .server(let message): return message
        }
    }
}

enum SummaryAPI {
    static let defaultBaseURL = "https://gwanson.kro.kr"

    private struct SubmitBody: Encodable {
        let url: String
        let clientID: String
        let force: Bool

        enum CodingKeys: String, CodingKey {
            case url
            case clientID = "client_id"
            case force
        }
    }

    private struct Response: Decodable {
        let id: String
        let status: SummaryStatus
        let summary: String?
        let error: String?
    }

    private struct ErrorResponse: Decodable {
        let error: String
        let message: String?
    }

    static func markPending(linkID: UUID) {
        UserDefaults.shared.saveSummaryRecord(
            SummaryRecord(
                linkID: linkID,
                status: .pending,
                updatedAt: Date()
            )
        )
    }

    @discardableResult
    static func submit(linkID: UUID, url: String, force: Bool = false) async throws -> SummaryRecord {
        var request = URLRequest(url: try endpoint("summaries"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            SubmitBody(
                url: url,
                clientID: UserDefaults.shared.summaryInstallationID,
                force: force
            )
        )
        let response: Response
        do {
            response = try await send(request)
        } catch let error as SummaryAPIError {
            saveFailure(linkID: linkID, error: error)
            throw error
        }
        let record = SummaryRecord(
            linkID: linkID,
            jobID: response.id,
            status: response.status,
            summary: response.summary,
            error: response.error,
            updatedAt: Date()
        )
        UserDefaults.shared.saveSummaryRecord(record)
        return record
    }

    @discardableResult
    static func sync(linkID: UUID, url: String) async throws -> SummaryRecord? {
        guard let current = UserDefaults.shared.summaryRecord(for: linkID) else { return nil }
        if current.status == .pending || current.jobID == nil {
            return try await submit(linkID: linkID, url: url)
        }
        guard current.status == .queued || current.status == .processing,
              let jobID = current.jobID else { return current }

        var request = URLRequest(url: try endpoint("summaries/\(jobID)"))
        request.setValue(UserDefaults.shared.summaryInstallationID, forHTTPHeaderField: "X-Client-ID")
        let response: Response
        do {
            response = try await send(request)
        } catch let error as SummaryAPIError {
            saveFailure(linkID: linkID, jobID: jobID, error: error)
            throw error
        }
        let record = SummaryRecord(
            linkID: linkID,
            jobID: response.id,
            status: response.status,
            summary: response.summary,
            error: response.error,
            updatedAt: Date()
        )
        UserDefaults.shared.saveSummaryRecord(record)
        return record
    }

    private static func endpoint(_ path: String) throws -> URL {
        let configured = UserDefaults.shared.string(forKey: UserDefaults.Keys.summaryAPIBaseURL)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let raw = configured.flatMap { $0.isEmpty ? nil : $0 } ?? defaultBaseURL
        guard let baseURL = URL(string: raw),
              let scheme = baseURL.scheme?.lowercased(),
              scheme == "https" || (scheme == "http" && ["127.0.0.1", "localhost"].contains(baseURL.host))
        else { throw SummaryAPIError.invalidServerURL }
        return baseURL.appendingPathComponent(path)
    }

    private static func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SummaryAPIError.server("서버 응답을 확인할 수 없습니다.")
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            let error = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw SummaryAPIError.server(error?.message ?? message(for: error?.error))
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    private static func message(for code: String?) -> String {
        switch code {
        case "daily_limit": return "오늘 사용할 수 있는 요약 3회를 모두 사용했습니다."
        case "server_daily_limit": return "오늘 서버의 요약 한도가 모두 사용됐습니다. 내일 다시 시도해주세요."
        case "queue_full": return "요약 요청이 많습니다. 잠시 후 다시 시도해주세요."
        case "not_found": return "요약 요청을 찾을 수 없습니다. 다시 요청해주세요."
        default: return "요약 요청에 실패했습니다."
        }
    }

    private static func saveFailure(linkID: UUID, jobID: String? = nil, error: SummaryAPIError) {
        UserDefaults.shared.saveSummaryRecord(
            SummaryRecord(
                linkID: linkID,
                jobID: jobID,
                status: .failed,
                error: error.localizedDescription,
                updatedAt: Date()
            )
        )
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
