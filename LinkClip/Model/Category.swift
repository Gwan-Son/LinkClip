//
//  Category.swift
//  LinkClip
//
//  Created by 심관혁 on 4/11/25.
//

import Foundation

struct Category: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var icon: String
    var subCategories: [Category]? = nil
    
    // 미리보기용 샘플데이터
    static func sampleCategories() -> [Category] {
        return [
            Category(
                name: "업무".localized(),
                icon: "briefcase",
                subCategories: [
                    Category(name: "회의".localized(), icon: "person.3"),
                    Category(name: "프로젝트".localized(), icon: "list.clipboard")
                ]
            ),
            Category(
                name: "학습".localized(),
                icon: "book",
                subCategories: [
                    Category(name: "프로그래밍".localized(), icon: "laptopcomputer"),
                    Category(name: "언어".localized(), icon: "text.bubble")
                ]
            ),
            Category(
                name: "개인".localized(),
                icon: "person"
            )
        ]
    }
}
