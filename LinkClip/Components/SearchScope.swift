//
//  SearchScope.swift
//  LinkClip
//
//  Created by 심관혁 on 4/2/25.
//

import Foundation

enum SearchScope: String, CaseIterable {
    case all = "All"
    case title = "Title"
    case url = "URL"
    case memo = "Memo"
}
