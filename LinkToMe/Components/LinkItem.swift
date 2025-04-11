//
//  LinkItem.swift
//  LinkToMe
//
//  Created by 심관혁 on 2/18/25.
//

import SwiftData
import Foundation

@Model
class CategoryItem {
    var id: UUID
    var name: String
    var icon: String
    var parentCategory: CategoryItem?
    
    @Relationship(deleteRule: .cascade, inverse: \CategoryItem.parentCategory)
    var subCategories: [CategoryItem]?
    
    @Relationship(deleteRule: .nullify, inverse: \LinkItem.category)
    var links: [LinkItem]?
    
    init(name: String, icon: String, parentCategory: CategoryItem? = nil) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.parentCategory = parentCategory
        self.subCategories = []
        self.links = []
    }
}

@Model
final class LinkItem {
    var id: UUID
    var url: String
    var title: String
    var personalMemo: String?
    var savedDate: Date
    var category: CategoryItem?
    init(url: String, title: String, personalMemo: String? = nil, category: CategoryItem? = nil) {
        self.id = UUID()
        self.url = url
        self.title = title
        self.personalMemo = personalMemo
        self.savedDate = Date()
        self.category = category
    }
}
