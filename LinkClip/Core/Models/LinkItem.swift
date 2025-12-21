//
//  LinkItem.swift
//  LinkClip
//
//  Created by 심관혁 on 2/18/25.
//

import Foundation
import SwiftData

@Model
class CategoryItem {
    var id: UUID
    var name: String
    var icon: String
    var color: String?
    var createdDate: Date?

    // 호환성을 위해 유지 (사용하지 않음)
    var parentCategory: CategoryItem?

    @Relationship(deleteRule: .nullify, inverse: \LinkItem.categories)
    var links: [LinkItem]?

    init(name: String, icon: String, color: String? = nil) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.color = color ?? CategoryItem.randomColor()
        self.createdDate = Date()
        self.parentCategory = nil // 항상 nil로 설정
        self.links = []
    }

    // 마이그레이션 후 color가 nil인 경우를 위한 computed property
    var safeColor: String {
        get { color ?? CategoryItem.randomColor() }
        set { color = newValue }
    }

    static func randomColor() -> String {
        let colors = [
            "FF6B6B", // 빨강
            "4ECDC4", // 청록
            "45B7D1", // 파랑
            "96CEB4", // 민트
            "FFEAA7", // 노랑
            "DDA0DD", // 자주
            "98D8C8", // 연두
            "F7DC6F", // 금색
            "BB8FCE", // 보라
            "85C1E9", // 하늘
            "F8C471", // 주황
            "82E0AA", // 라임
        ]
        return colors.randomElement() ?? "FF6B6B"
    }
}

@Model
final class LinkItem {
    var id: UUID
    @Attribute(.unique) var url: String
    var title: String
    var personalMemo: String?
    var savedDate: Date
    var categories: [CategoryItem]?

    // 메타데이터 속성들
    var metaDescription: String?  // 웹페이지 설명
    var imageURL: String?  // 썸네일 이미지 URL
    var siteName: String?  // 사이트 이름
    var faviconURL: String?  // 파비콘 URL
    var isMetadataLoaded: Bool?  // 메타데이터 로드 완료 여부
    var metadataLoadDate: Date?  // 메타데이터 로드 날짜
    
    init(
        url: String, title: String, personalMemo: String? = nil, categories: [CategoryItem]? = nil,
        metaDescription: String? = nil, imageURL: String? = nil, siteName: String? = nil,
        faviconURL: String? = nil, isMetadataLoaded: Bool? = false, metadataLoadDate: Date? = nil
    ) {
        self.id = UUID()
        self.url = url
        self.title = title
        self.personalMemo = personalMemo
        self.savedDate = Date()
        self.categories = categories
        self.metaDescription = metaDescription
        self.imageURL = imageURL
        self.siteName = siteName
        self.faviconURL = faviconURL
        self.isMetadataLoaded = isMetadataLoaded
        self.metadataLoadDate = metadataLoadDate
    }

    // 타입 안전한 URL 접근을 위한 계산 속성
    var urlValue: URL? {
        URL(string: url)
    }

    // 기존 코드와의 호환성을 위한 편의 초기화 메서드
    convenience init(
        url: String, title: String, personalMemo: String? = nil, categories: [CategoryItem]? = nil
    ) {
        self.init(
            url: url,
            title: title,
            personalMemo: personalMemo,
            categories: categories,
            metaDescription: nil,
            imageURL: nil,
            siteName: nil,
            faviconURL: nil,
            isMetadataLoaded: false,
            metadataLoadDate: nil
        )
    }
}
