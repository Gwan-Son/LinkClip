//
//  LinkItem.swift
//  LinkToMe
//
//  Created by 심관혁 on 2/18/25.
//

import SwiftData
import Foundation

@Model
final class LinkItem {
    @Attribute(.externalStorage)
    var url: String
    var title: String
    var personalMemo: String?
    var savedDate: Date
    init(url: String, title: String, personalMemo: String? = nil) {
        self.url = url
        self.title = title
        self.personalMemo = personalMemo
        self.savedDate = Date()
    }
}
