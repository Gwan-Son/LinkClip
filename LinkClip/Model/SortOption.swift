//
//  SortOption.swift
//  LinkClip
//
//  Created by 심관혁 on 4/2/25.
//

import Foundation
import SwiftUI

enum SortOption: CaseIterable, Identifiable {
    case dateNewest
    case dateOldest
    case titleAtoZ
    case titleZtoA

    var id: Self { self }

    var displayName: LocalizedStringResource {
        switch self {
        case .dateNewest:
            return LocalizedStringResource("sort_date_newest", defaultValue: "최신순")
        case .dateOldest:
            return LocalizedStringResource("sort_date_oldest", defaultValue: "오래된순")
        case .titleAtoZ:
            return LocalizedStringResource("sort_title_az", defaultValue: "제목 (A-Z)")
        case .titleZtoA:
            return LocalizedStringResource("sort_title_za", defaultValue: "제목 (Z-A)")
        }
    }
}
