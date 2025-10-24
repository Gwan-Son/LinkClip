//
//  SwiftDataLinkRepository.swift
//  LinkClip
//
//  Created by 심관혁 on 10/24/25.
//

import Foundation
import SwiftData

final class SwiftDataLinkRepository: LinkRepository {
    private var modelContext: ModelContext?

    func setContextIfNeeded(_ context: ModelContext) {
        if modelContext == nil { modelContext = context }
    }

    func fetchAll() throws -> [LinkItem] {
        guard let modelContext = modelContext else { return [] }
        let descriptor = FetchDescriptor<LinkItem>(sortBy: [
            SortDescriptor(\.savedDate, order: .reverse)
        ])
        return try modelContext.fetch(descriptor)
    }

    func exists(urlString: String) throws -> Bool {
        guard let modelContext = modelContext else { return false }
        let predicate = #Predicate<LinkItem> { $0.url == urlString }
        var descriptor = FetchDescriptor<LinkItem>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first != nil
    }

    func findByURLString(_ urlString: String) throws -> LinkItem? {
        guard let modelContext = modelContext else { return nil }
        let predicate = #Predicate<LinkItem> { $0.url == urlString }
        var descriptor = FetchDescriptor<LinkItem>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    func delete(_ link: LinkItem) {
        modelContext?.delete(link)
    }

    func filter(_ links: [LinkItem], by searchText: String, scope: SearchScope) -> [LinkItem] {
        guard !searchText.isEmpty else { return links }
        return links.filter { link in
            switch scope {
            case .all:
                return link.title.localizedCaseInsensitiveContains(searchText)
                || link.url.localizedCaseInsensitiveContains(searchText)
                || (link.personalMemo ?? "").localizedCaseInsensitiveContains(searchText)
            case .title:
                return link.title.localizedCaseInsensitiveContains(searchText)
            case .url:
                return link.url.localizedCaseInsensitiveContains(searchText)
            case .memo:
                return (link.personalMemo ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func sort(_ links: [LinkItem], by option: SortOption) -> [LinkItem] {
        switch option {
        case .dateNewest:
            return links.sorted { $0.savedDate > $1.savedDate }
        case .dateOldest:
            return links.sorted { $0.savedDate < $1.savedDate }
        case .titleAtoZ:
            return links.sorted { $0.title < $1.title }
        case .titleZtoA:
            return links.sorted { $0.title > $1.title }
        }
    }
}
