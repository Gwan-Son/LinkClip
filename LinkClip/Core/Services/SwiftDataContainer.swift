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
        static let readLinkIDs = "readLinkIDs"
        static let readLaterLinkIDs = "readLaterLinkIDs"
        static let linkReminderDates = "linkReminderDates"
        static let categoryOrder = "categoryOrder"
        static let summaryInstallationID = "summaryInstallationID"
        static let summaryLinkIDs = "summaryLinkIDs"
        static let summaryAuthToken = "summaryAuthToken"
        static let summaryAuthExpiration = "summaryAuthExpiration"
        static let appAttestKeyID = "appAttestKeyID"
        static let pendingSummaryNotificationID = "pendingSummaryNotificationID"
        static let pendingNotificationType = "pendingNotificationType"
        static let summaryUsage = "summaryUsage"
        static let onboardingVersion = "onboardingVersion"
        static let defaultSortOption = "defaultSortOption"
        static let appearance = "appearance"
        static let shareRequestsSummary = "shareRequestsSummary"
    }

    var favoriteLinkIDs: Set<UUID> {
        get { Set(stringArray(forKey: Keys.favoriteLinkIDs)?.compactMap(UUID.init) ?? []) }
        set { set(newValue.map(\.uuidString), forKey: Keys.favoriteLinkIDs) }
    }

    var readLinkIDs: Set<UUID> {
        get { Set(stringArray(forKey: Keys.readLinkIDs)?.compactMap(UUID.init) ?? []) }
        set { set(newValue.map(\.uuidString), forKey: Keys.readLinkIDs) }
    }

    var readLaterLinkIDs: Set<UUID> {
        get { Set(stringArray(forKey: Keys.readLaterLinkIDs)?.compactMap(UUID.init) ?? []) }
        set { set(newValue.map(\.uuidString), forKey: Keys.readLaterLinkIDs) }
    }

    var linkReminderDates: [UUID: Date] {
        get {
            guard let data = data(forKey: Keys.linkReminderDates),
                  let values = try? JSONDecoder().decode([String: Date].self, from: data) else {
                return [:]
            }
            return Dictionary(uniqueKeysWithValues: values.compactMap {
                guard let id = UUID(uuidString: $0.key) else { return nil }
                return (id, $0.value)
            })
        }
        set {
            let values = Dictionary(uniqueKeysWithValues: newValue.map { ($0.key.uuidString, $0.value) })
            set(try? JSONEncoder().encode(values), forKey: Keys.linkReminderDates)
        }
    }

    var categoryOrder: [UUID] {
        get { stringArray(forKey: Keys.categoryOrder)?.compactMap(UUID.init) ?? [] }
        set { set(newValue.map(\.uuidString), forKey: Keys.categoryOrder) }
    }

    var defaultSortOptionRawValue: String {
        get { string(forKey: Keys.defaultSortOption) ?? "dateNewest" }
        set { set(newValue, forKey: Keys.defaultSortOption) }
    }

    var shareRequestsSummary: Bool {
        get { object(forKey: Keys.shareRequestsSummary) as? Bool ?? true }
        set { set(newValue, forKey: Keys.shareRequestsSummary) }
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
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .summaryStatusChanged, object: record.linkID)
        }
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

    func linkID(forSummaryIdentifier identifier: String) -> UUID? {
        for value in stringArray(forKey: Keys.summaryLinkIDs) ?? [] {
            guard let linkID = UUID(uuidString: value),
                  let record = summaryRecord(for: linkID) else { continue }
            if value == identifier || record.jobID == identifier { return linkID }
        }
        return nil
    }

    var summaryUsage: SummaryUsage? {
        get {
            data(forKey: Keys.summaryUsage)
                .flatMap { try? JSONDecoder().decode(SummaryUsage.self, from: $0) }
        }
        set {
            guard let newValue, let data = try? JSONEncoder().encode(newValue) else {
                removeObject(forKey: Keys.summaryUsage)
                return
            }
            set(data, forKey: Keys.summaryUsage)
        }
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

extension Notification.Name {
    static let summaryStatusChanged = Notification.Name("SummaryStatusChanged")
}

enum SummaryStatus: String, Codable {
    case pending
    case queued
    case processing
    case completed
    case failed
}

struct SummaryUsage: Codable, Equatable {
    let remainingRequests: Int
    let resetAt: String?
}

struct SuggestedSummaryTag: Codable, Equatable {
    let name: String
    let confidence: Double?
}

struct SummaryRecord: Codable, Equatable, Identifiable {
    var id: UUID { linkID }
    let linkID: UUID
    var jobID: String?
    var status: SummaryStatus
    var summary: String?
    var suggestedTags: [SuggestedSummaryTag]? = nil
    var error: String?
    var errorCode: String? = nil
    var remainingRequests: Int? = nil
    var resetAt: String? = nil
    var updatedAt: Date
}

enum SummaryAPIError: LocalizedError {
    case server(code: String?, message: String)
    case network

    var errorDescription: String? {
        switch self {
        case .server(_, let message): return message
        case .network: return String(localized: "네트워크 연결을 확인해주세요.")
        }
    }

    var code: String? {
        if case .server(let code, _) = self { return code }
        return "network"
    }
}

enum SummaryAPI {
    static let defaultBaseURL = "https://gwanson.kro.kr"

    private struct SubmitBody: Encodable {
        let url: String
        let clientID: String
        let force: Bool
        let availableTags: [String]

        enum CodingKeys: String, CodingKey {
            case url
            case clientID = "client_id"
            case force
            case availableTags = "available_tags"
        }
    }

    private struct Response: Decodable {
        let id: String
        let status: SummaryStatus
        let summary: String?
        let suggestedTags: [SuggestedSummaryTag]?
        let error: String?
        let remainingRequests: Int?
        let resetAt: String?

        enum CodingKeys: String, CodingKey {
            case id, status, summary, error, remaining
            case suggestedTags = "suggested_tags"
            case remainingRequests = "remaining_requests"
            case resetAt = "reset_at"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            status = try values.decode(SummaryStatus.self, forKey: .status)
            summary = try values.decodeIfPresent(String.self, forKey: .summary)
            suggestedTags = try values.decodeIfPresent([SuggestedSummaryTag].self, forKey: .suggestedTags)
            error = try values.decodeIfPresent(String.self, forKey: .error)
            remainingRequests = try values.decodeIfPresent(Int.self, forKey: .remainingRequests)
                ?? values.decodeIfPresent(Int.self, forKey: .remaining)
            resetAt = try values.decodeIfPresent(String.self, forKey: .resetAt)
        }
    }

    private struct ErrorResponse: Decodable {
        let error: String
        let message: String?
    }

    private struct UsageResponse: Decodable {
        let remainingRequests: Int
        let resetAt: String?

        enum CodingKeys: String, CodingKey {
            case remaining, resetAt = "reset_at"
            case remainingRequests = "remaining_requests"
        }

        init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            remainingRequests = try values.decodeIfPresent(Int.self, forKey: .remainingRequests)
                ?? values.decode(Int.self, forKey: .remaining)
            resetAt = try values.decodeIfPresent(String.self, forKey: .resetAt)
        }
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
    static func submit(
        linkID: UUID,
        url: String,
        force: Bool = false,
        availableTags: [String] = []
    ) async throws -> SummaryRecord {
        var request = URLRequest(url: try endpoint("summaries"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            SubmitBody(
                url: url,
                clientID: UserDefaults.shared.summaryInstallationID,
                force: force,
                availableTags: Array(availableTags.prefix(50))
            )
        )
        authorize(&request)
        let response: Response
        do {
            response = try await send(request)
        } catch {
            let apiError = error as? SummaryAPIError ?? .network
            saveFailure(linkID: linkID, error: apiError)
            throw apiError
        }
        let record = SummaryRecord(
            linkID: linkID,
            jobID: response.id,
            status: response.status,
            summary: response.summary,
            suggestedTags: response.suggestedTags,
            error: response.error,
            remainingRequests: response.remainingRequests,
            resetAt: response.resetAt,
            updatedAt: Date()
        )
        UserDefaults.shared.saveSummaryRecord(record)
        saveUsage(remaining: response.remainingRequests, resetAt: response.resetAt)
        return record
    }

    @discardableResult
    static func sync(
        linkID: UUID,
        url: String,
        availableTags: [String] = []
    ) async throws -> SummaryRecord? {
        guard let current = UserDefaults.shared.summaryRecord(for: linkID) else { return nil }
        if current.status == .pending || current.jobID == nil {
            return try await submit(linkID: linkID, url: url, availableTags: availableTags)
        }
        guard current.status == .queued || current.status == .processing,
              let jobID = current.jobID else { return current }

        var request = URLRequest(url: try endpoint("summaries/\(jobID)"))
        request.setValue(UserDefaults.shared.summaryInstallationID, forHTTPHeaderField: "X-Client-ID")
        authorize(&request)
        let response: Response
        do {
            response = try await send(request)
        } catch {
            let apiError = error as? SummaryAPIError ?? .network
            saveFailure(linkID: linkID, jobID: jobID, error: apiError)
            throw apiError
        }
        let record = SummaryRecord(
            linkID: linkID,
            jobID: response.id,
            status: response.status,
            summary: response.summary,
            suggestedTags: response.suggestedTags ?? current.suggestedTags,
            error: response.error,
            remainingRequests: response.remainingRequests ?? current.remainingRequests,
            resetAt: response.resetAt ?? current.resetAt,
            updatedAt: Date()
        )
        UserDefaults.shared.saveSummaryRecord(record)
        saveUsage(remaining: response.remainingRequests, resetAt: response.resetAt)
        return record
    }

    @discardableResult
    static func refreshUsage() async throws -> SummaryUsage {
        var request = URLRequest(url: try endpoint("usage"))
        request.setValue(UserDefaults.shared.summaryInstallationID, forHTTPHeaderField: "X-Client-ID")
        authorize(&request)
        let response: UsageResponse = try await send(request)
        let usage = SummaryUsage(
            remainingRequests: response.remainingRequests,
            resetAt: response.resetAt
        )
        UserDefaults.shared.summaryUsage = usage
        return usage
    }

    static func endpoint(_ path: String) throws -> URL {
        URL(string: defaultBaseURL)!.appendingPathComponent(path)
    }

    static func authorize(_ request: inout URLRequest) {
        if let token = UserDefaults.shared.string(forKey: UserDefaults.Keys.summaryAuthToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    static func registerDeviceToken(_ token: String) async throws {
        struct Body: Encodable {
            let client_id: String
            let device_token: String
            let environment: String
        }
        var request = URLRequest(url: try endpoint("devices"))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        #if DEBUG
        let environment = "development"
        #else
        let environment = "production"
        #endif
        request.httpBody = try JSONEncoder().encode(
            Body(
                client_id: UserDefaults.shared.summaryInstallationID,
                device_token: token,
                environment: environment
            )
        )
        authorize(&request)
        let _: EmptyResponse = try await send(request)
    }

    private struct EmptyResponse: Decodable {}

    private static func send<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw SummaryAPIError.server(
                code: "invalid_response",
                message: String(localized: "서버 응답을 확인할 수 없습니다.")
            )
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            if httpResponse.statusCode == 401 {
                UserDefaults.shared.removeObject(forKey: UserDefaults.Keys.summaryAuthToken)
                UserDefaults.shared.removeObject(forKey: UserDefaults.Keys.summaryAuthExpiration)
            }
            let error = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw SummaryAPIError.server(
                code: error?.error,
                message: message(for: error?.error, fallback: error?.message)
            )
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw SummaryAPIError.server(
                code: "invalid_response",
                message: String(localized: "서버 응답을 확인할 수 없습니다.")
            )
        }
    }

    private static func message(for code: String?, fallback: String? = nil) -> String {
        switch code {
        case "daily_limit":
            return String(localized: "오늘 사용할 수 있는 요약 3회를 모두 사용했습니다.")
        case "server_daily_limit":
            return String(localized: "오늘 서버의 요약 한도가 모두 사용됐습니다. 내일 다시 시도해주세요.")
        case "queue_full":
            return String(localized: "요약 요청이 많습니다. 잠시 후 다시 시도해주세요.")
        case "not_found":
            return String(localized: "요약 요청을 찾을 수 없습니다. 다시 요청해주세요.")
        default:
            return fallback ?? String(localized: "요약 요청에 실패했습니다.")
        }
    }

    private static func saveFailure(linkID: UUID, jobID: String? = nil, error: SummaryAPIError) {
        UserDefaults.shared.saveSummaryRecord(
            SummaryRecord(
                linkID: linkID,
                jobID: jobID,
                status: .failed,
                error: error.localizedDescription,
                errorCode: error.code,
                updatedAt: Date()
            )
        )
    }

    private static func saveUsage(remaining: Int?, resetAt: String?) {
        guard let remaining else { return }
        UserDefaults.shared.summaryUsage = SummaryUsage(
            remainingRequests: remaining,
            resetAt: resetAt ?? UserDefaults.shared.summaryUsage?.resetAt
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
