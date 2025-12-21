//
//  SampleData.swift
//  LinkClip
//
//  Created by 심관혁 on 10/24/25.
//

import Foundation

struct SampleCategory: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var icon: String
    var subCategories: [SampleCategory]? = nil
}

extension SampleCategory {
    static func sampleCategories() -> [SampleCategory] {
        return [
            SampleCategory(
                name: String(localized: "업무"),
                icon: "briefcase",
                subCategories: [
                    SampleCategory(name: String(localized: "회의"), icon: "person.3"),
                    SampleCategory(name: String(localized: "프로젝트"), icon: "list.clipboard"),
                ]
            ),
            SampleCategory(
                name: String(localized: "학습"),
                icon: "book",
                subCategories: [
                    SampleCategory(name: String(localized: "프로그래밍"), icon: "laptopcomputer"),
                    SampleCategory(name: String(localized: "언어"), icon: "text.bubble"),
                ]
            ),
            SampleCategory(
                name: String(localized: "개인"),
                icon: "person"
            ),
        ]
    }
}
