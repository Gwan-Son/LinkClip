//
//  SearchScope.swift
//  LinkToMe
//
//  Created by 심관혁 on 4/2/25.
//

import Foundation

enum SearchScope: String, CaseIterable {
    case all = "전체"
    case title = "제목"
    case url = "URL"
    case memo = "메모"
}
