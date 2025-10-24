//
//  LinkRepository.swift
//  LinkClip
//
//  Created by 심관혁 on 10/24/25.
//

import Foundation
import SwiftData

protocol LinkRepository {
    func setContextIfNeeded(_ context: ModelContext)
    func fetchAll() throws -> [LinkItem]
    func exists(urlString: String) throws -> Bool
    func findByURLString(_ urlString: String) throws -> LinkItem?
    func delete(_ link: LinkItem)
    func filter(_ links: [LinkItem], by searchText: String, scope: SearchScope) -> [LinkItem]
    func sort(_ links: [LinkItem], by option: SortOption) -> [LinkItem]
}
