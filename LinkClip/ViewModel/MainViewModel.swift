//
//  MainViewModel.swift
//  LinkClip
//
//  Created by 심관혁 on 4/10/25.
//

import SwiftData
import SwiftUI

@MainActor
final class MainViewModel: ObservableObject {
    // 모델 컨텍스트
    var modelContext: ModelContext?

    // 서비스 의존성 (DI)
    private let urlOpener: URLOpener
    private let clipboard: ClipboardService
    private let linkRepository: LinkRepository
    private let spotlight: SpotlightIndexing

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

    // 초기화: 서비스 주입
    init(
        urlOpener: URLOpener,
        clipboard: ClipboardService,
        linkRepository: LinkRepository,
        spotlight: SpotlightIndexing
    ) {
        self.urlOpener = urlOpener
        self.clipboard = clipboard
        self.linkRepository = linkRepository
        self.spotlight = spotlight
    }

    convenience init() {
        self.init(
            urlOpener: SystemURLOpener(),
            clipboard: SystemClipboardService(),
            linkRepository: SwiftDataLinkRepository(),
            spotlight: SpotlightIndexingService()
        )
    }

    // 필터링 로직
    func filterLinks(_ links: [LinkItem]) -> [LinkItem] {
        linkRepository.filter(links, by: searchText, scope: searchScope)
    }

    // 정렬 로직
    func sortLinks(_ links: [LinkItem]) -> [LinkItem] {
        linkRepository.sort(links, by: sortOption)
    }

    // 삭제 함수 (저장 및 Spotlight 삭제까지 보장)
    func deleteLink(_ link: LinkItem) async {
        guard let context = modelContext else { return }
        linkRepository.delete(link)
        do {
            try context.save()
            await spotlight.delete(linkId: link.id)
        } catch {
            toastMessage = String(localized: "삭제 중 오류가 발생했습니다.")
            withAnimation { showToast = true }
        }
    }

    // URL 열기 함수
    func openURL(_ urlString: String) {
        if let url = URL(string: urlString) {
            urlOpener.open(url)
        }
    }

    // URL 복사 함수
    func copyURL(_ urlString: String) {
        clipboard.copy(urlString)
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

    // ModelContext가 비어있을 때만 주입
    func setContextIfNeeded(_ context: ModelContext) {
        if modelContext == nil {
            modelContext = context
        }
        linkRepository.setContextIfNeeded(context)
    }

    func saveNewLink(_ link: LinkItem, in context: ModelContext) async {
        context.insert(link)
        do {
            try context.save()
            await spotlight.index(link: link)
        } catch {
            // 에러 발생 시 사용자에게 토스트로 알림
            toastMessage = String(localized: "저장 중 오류가 발생했습니다.")
            withAnimation { showToast = true }
        }
    }

    // 과거 API 정리: context를 외부에서 받지 않고 내부 보유 context 사용
}
