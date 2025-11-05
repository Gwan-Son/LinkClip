//
//  SpotlightIndexingService.swift
//  LinkClip
//
//  Created by 심관혁 on 10/26/25.
//

import CoreSpotlight
import Foundation
import UniformTypeIdentifiers

protocol SpotlightIndexing {
    // LinkItem 기반 API: 메인 액터 격리 (SwiftData 모델은 Sendable 아님)
    @MainActor func index(link: LinkItem) async
    @MainActor func indexAll(_ links: [LinkItem]) async

    // Sendable DTO 기반 API: 백그라운드 안전 호출
    func indexEntry(_ entry: SpotlightEntry) async
    func indexAllEntries(_ entries: [SpotlightEntry]) async

    // 삭제는 ID만 필요하므로 비격리 가능
    func delete(linkId: UUID) async
    func deleteAll() async
}

// Sendable DTO로 액터 경계 안전 통과용 구조체
struct SpotlightEntry: Sendable {
    let id: UUID
    let urlString: String?
    let title: String
    let personalMemo: String?
    let metaDescription: String?
    let imageURL: String?
    let siteName: String?
    let faviconURL: String?
    let savedDate: Date
    let metadataLoadDate: Date?
    let categoryId: UUID?
}

final class SpotlightIndexingService: SpotlightIndexing {

    private let index = CSSearchableIndex.default()

    @MainActor
    func index(link: LinkItem) async {
        let item = makeSearchableItem(from: link)
        await indexItems([item])
    }

    @MainActor
    func indexAll(_ links: [LinkItem]) async {
        let batchSize = 100
        var batch: [CSSearchableItem] = []
        batch.reserveCapacity(batchSize)

        for link in links {
            batch.append(makeSearchableItem(from: link))
            if batch.count == batchSize {
                await indexItems(batch)
                batch.removeAll(keepingCapacity: true)
            }
        }
        if !batch.isEmpty {
            await indexItems(batch)
        }
    }

    func indexEntry(_ entry: SpotlightEntry) async {
        let item = makeSearchableItem(from: entry)
        await indexItems([item])
    }

    func indexAllEntries(_ entries: [SpotlightEntry]) async {
        let batchSize = 100
        var batch: [CSSearchableItem] = []
        batch.reserveCapacity(batchSize)

        for entry in entries {
            batch.append(makeSearchableItem(from: entry))
            if batch.count == batchSize {
                await indexItems(batch)
                batch.removeAll(keepingCapacity: true)
            }
        }
        if !batch.isEmpty {
            await indexItems(batch)
        }
    }

    func delete(linkId: UUID) async {
        await withCheckedContinuation { cont in
            index.deleteSearchableItems(withIdentifiers: [linkId.uuidString]) { _ in
                cont.resume()
            }
        }
    }

    func deleteAll() async {
        await withCheckedContinuation { cont in
            index.deleteAllSearchableItems { _ in
                cont.resume()
            }
        }
    }

    private func makeSearchableItem(from link: LinkItem) -> CSSearchableItem {
        let attr = CSSearchableItemAttributeSet(contentType: .url)
        attr.title = link.title
        attr.displayName = link.title
        attr.contentDescription = link.personalMemo ?? link.metaDescription
        attr.keywords = makeKeywords(fromTitle: link.title,
                                     siteName: link.siteName,
                                     urlString: link.url,
                                     categoryName: link.category?.name)

        if let url = URL(string: link.url) {
            attr.url = url
        }

        attr.contentCreationDate = link.savedDate
        attr.contentModificationDate = link.metadataLoadDate ?? link.savedDate
        attr.lastUsedDate = Date()

        if let thumb = link.faviconURL ?? link.imageURL, let turl = URL(string: thumb) {
            attr.thumbnailURL = turl
        }

        let domainId = link.category?.id.uuidString ?? "uncategorized"

        return CSSearchableItem(
            uniqueIdentifier: link.id.uuidString,
            domainIdentifier: domainId,
            attributeSet: attr
        )
    }

    private func makeSearchableItem(from entry: SpotlightEntry) -> CSSearchableItem {
        let attr = CSSearchableItemAttributeSet(contentType: .url)
        attr.title = entry.title
        attr.displayName = entry.title
        attr.contentDescription = entry.personalMemo ?? entry.metaDescription
        attr.keywords = makeKeywords(fromTitle: entry.title,
                                     siteName: entry.siteName,
                                     urlString: entry.urlString,
                                     categoryName: nil)

        if let u = entry.urlString, let url = URL(string: u) {
            attr.url = url
        }

        attr.contentCreationDate = entry.savedDate
        attr.contentModificationDate = entry.metadataLoadDate ?? entry.savedDate
        attr.lastUsedDate = Date()

        if let thumb = entry.faviconURL ?? entry.imageURL, let turl = URL(string: thumb) {
            attr.thumbnailURL = turl
        }

        let domainId = entry.categoryId?.uuidString ?? "uncategorized"

        return CSSearchableItem(
            uniqueIdentifier: entry.id.uuidString,
            domainIdentifier: domainId,
            attributeSet: attr
        )
    }

    private func makeKeywords(fromTitle title: String,
                              siteName: String?,
                              urlString: String?,
                              categoryName: String?) -> [String] {
        var words: Set<String> = []
        if let categoryName, !categoryName.isEmpty { words.insert(categoryName) }
        if let siteName, !siteName.isEmpty { words.insert(siteName) }
        if let host = (urlString.flatMap { URL(string: $0)?.host }) { words.insert(host) }
        title
            .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .filter { $0.count > 1 }
            .forEach { words.insert($0) }
        return Array(words)
    }

    private func indexItems(_ items: [CSSearchableItem]) async {
        guard !items.isEmpty else { return }
        await withCheckedContinuation { cont in
            index.indexSearchableItems(items) { _ in
                cont.resume()
            }
        }
    }
}
