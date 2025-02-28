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
//    @Attribute(.unique) var id: UUID
    @Attribute(.externalStorage)
    var url: URL
    init(url: URL) {
        self.url = url
    }
//    var id: UUID
//    var url: URL
//    var title: String
//    var createdDate: Date
//    var previewImage: Data?
//    @Relationship var tags: [Tag]
//    
//    init(url: URL, title: String, tags: [Tag] = []) {
//        self.id = UUID()
//        self.url = url
//        self.title = title
//        self.createdDate = Date()
//        self.tags = tags
//    }
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
