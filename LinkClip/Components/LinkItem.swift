//
//  LinkItem.swift
//  LinkClip
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
    
    // 메타데이터 속성들
    var metaDescription: String?     // 웹페이지 설명
    var imageURL: String?           // 썸네일 이미지 URL
    var siteName: String?           // 사이트 이름
    var faviconURL: String?         // 파비콘 URL
    var isMetadataLoaded: Bool      // 메타데이터 로드 완료 여부
    var metadataLoadDate: Date?     // 메타데이터 로드 날짜
    
    init(url: String, title: String, personalMemo: String? = nil, category: CategoryItem? = nil, metaDescription: String? = nil, imageURL: String? = nil, siteName: String? = nil, faviconURL: String? = nil, isMetadataLoaded: Bool = false, metadataLoadDate: Date? = nil) {
        self.id = UUID()
        self.url = url
        self.title = title
        self.personalMemo = personalMemo
        self.savedDate = Date()
        self.category = category
        self.metaDescription = metaDescription
        self.imageURL = imageURL
        self.siteName = siteName
        self.faviconURL = faviconURL
        self.isMetadataLoaded = isMetadataLoaded
        self.metadataLoadDate = metadataLoadDate
    }
    
    // 기존 코드와의 호환성을 위한 편의 초기화 메서드
    convenience init(url: String, title: String, personalMemo: String? = nil, category: CategoryItem? = nil) {
        self.init(
            url: url,
            title: title,
            personalMemo: personalMemo,
            category: category,
            metaDescription: nil,
            imageURL: nil,
            siteName: nil,
            faviconURL: nil,
            isMetadataLoaded: false,
            metadataLoadDate: nil
        )
    }
}




