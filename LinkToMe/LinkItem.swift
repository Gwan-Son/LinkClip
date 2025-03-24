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
    var url: URL
    var title: String?
    var savedDate: Date
    init(url: URL, title: String? = nil) {
        self.url = url
        self.title = title
        self.savedDate = Date()
    }
}

//@Model
//final class Tag {
//    @Attribute(.unique) var name: String
//    @Relationship var links: [LinkItem] = []
//    
//    init(name: String, links: [LinkItem] = []) {
//        self.name = name
//    }
//}
