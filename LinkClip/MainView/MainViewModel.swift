//
//  MainViewModel.swift
//  LinkClip
//
//  Created by 심관혁 on 4/10/25.
//

import SwiftUI
import SwiftData

class MainViewModel: ObservableObject {
    // 모델 컨텍스트
    var modelContext: ModelContext?
    
    // 상태 변수들
    @Published var selectedURLForEditing: LinkItem?
    @Published var showOnboarding: Bool = false
    @Published var showSetting: Bool = false
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    @Published var searchText: String = ""
    @Published var searchScope: SearchScope = .all
    @Published var sortOption: SortOption = .dateNewest
    
    // AppStorage 래핑
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    // 필터링 로직
    func filterLinks(_ links: [LinkItem]) -> [LinkItem] {
        if searchText.isEmpty {
            return links
        } else {
            return links.filter { link in
                switch searchScope {
                case .all:
                    return link.title.localizedCaseInsensitiveContains(searchText) || link.url.localizedCaseInsensitiveContains(searchText) || (link.personalMemo ?? "").localizedCaseInsensitiveContains(searchText)
                case .title:
                    return link.title.localizedCaseInsensitiveContains(searchText)
                case .url:
                    return link.url.localizedCaseInsensitiveContains(searchText)
                case .memo:
                    return (link.personalMemo ?? "").localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
    
    // 정렬 로직
    func sortLinks(_ links: [LinkItem]) -> [LinkItem] {
        switch sortOption {
        case .dateNewest:
            return links.sorted { $0.savedDate > $1.savedDate }
        case .dateOldest:
            return links.sorted { $0.savedDate < $1.savedDate }
        case .titleAtoZ:
            return links.sorted { $0.title < $1.title }
        case .titleZtoA:
            return links.sorted { $0.title > $1.title }
        }
    }
    
    // 삭제 함수
    func deleteLink(_ link: LinkItem) {
        guard let modelContext = modelContext else { return }
        modelContext.delete(link)
    }
    
    // URL 열기 함수
    func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    // URL 복사 함수
    func copyURL(_ urlString: String) {
        UIPasteboard.general.string = urlString
        toastMessage = "URL이 복사되었습니다."
        withAnimation {
            showToast = true
        }
    }
    
    // 앱 시작 시 호출되는 함수
    func checkOnboarding() {
        if !hasSeenOnboarding {
            showOnboarding = true
            hasSeenOnboarding = true
        }
    }
}
