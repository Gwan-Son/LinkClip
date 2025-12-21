//
//  SearchScope.swift
//  LinkClip
//
//  Created by 심관혁 on 4/2/25.
//

import Foundation
import SwiftUI

enum SearchScope: CaseIterable {
    case all
    case title
    case url
    case memo

    var displayName: LocalizedStringResource {
        switch self {
        case .all:
            return LocalizedStringResource("search_scope_all", defaultValue: "전체")
        case .title:
            return LocalizedStringResource("search_scope_title", defaultValue: "제목")
        case .url:
            return LocalizedStringResource("search_scope_url", defaultValue: "URL")
        case .memo:
            return LocalizedStringResource("search_scope_memo", defaultValue: "메모")
        }
    }
}
