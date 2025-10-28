//
//  SpotlightIndexingService.swift
//  LinkClip
//
//  Created by 심관혁 on 10/26/25.
//

import CoreSpotlight
import Foundation
import UniformTypeIdentifiers

@MainActor
protocol SpotlightIndexing {
    func index(link: LinkItem) async
    func indexAll(_ links: [LinkItem]) async
    func delete(linkId: UUID) async
    func deleteAll() async
}

final class SpotlightIndexingService: SpotlightIndexing {

    private let index = CSSearchableIndex.default()

    func index(link: LinkItem) async {
        let item = makeSearchableItem(from: link)
        await indexItems([item])
    }

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
        attr.keywords = makeKeywords(from: link)

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

    private func makeKeywords(from link: LinkItem) -> [String] {
        var words: Set<String> = []
        if let categoryName = link.category?.name, !categoryName.isEmpty {
            words.insert(categoryName)
        }
        if let siteName = link.siteName, !siteName.isEmpty {
            words.insert(siteName)
        }
        if let host = URL(string: link.url)?.host {
            words.insert(host)
        }
        link.title
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
