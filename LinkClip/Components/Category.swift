//
//  Category.swift
//  LinkToMe
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
                name: "업무",
                icon: "briefcase",
                subCategories: [
                    Category(name: "회의", icon: "person.3"),
                    Category(name: "프로젝트", icon: "list.clipboard")
                ]
            ),
            Category(
                name: "학습",
                icon: "book",
                subCategories: [
                    Category(name: "프로그래밍", icon: "laptopcomputer"),
                    Category(name: "언어", icon: "text.bubble")
                ]
            ),
            Category(
                name: "개인",
                icon: "person"
            )
        ]
    }
}
