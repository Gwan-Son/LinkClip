//
//  HomeViewModel.swift
//  LinkClip
//
//  Created by 심관혁 on 12/15/25.
//

import SwiftData
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    // 카테고리 선택 상태
    @Published var selectedCategory: CategoryItem? = nil {
        didSet {
            updateFilteredLinks()
        }
    }

    // 정렬 옵션
    @Published var sortOption: SortOption = .dateNewest {
        didSet {
            updateFilteredLinks()
        }
    }

    // 필터링된 링크들
    @Published private(set) var filteredLinks: [LinkItem] = []

    // 모든 카테고리
    @Published private(set) var categories: [CategoryItem] = []

    // 모든 링크 (페이징용)
    @Published private(set) var allLinks: [LinkItem] = []

    private var modelContext: ModelContext?
    private var lastRefreshDate: Date?

    init() {
        // Darwin Notification 대신 ScenePhase를 통한 리프레시만 사용
        setupNotifications()
    }

    deinit {
        // 정리할 리소스 없음
    }

    func setContext(_ context: ModelContext) {
        guard modelContext == nil else { return }
        self.modelContext = context
        loadInitialData()
    }

    private func loadInitialData() {
        guard let context = modelContext else { return }

        do {
            // 모든 카테고리 로드
            let categoryDescriptor = FetchDescriptor<CategoryItem>(
                sortBy: [SortDescriptor(\.createdDate, order: .forward)]
            )
            categories = try context.fetch(categoryDescriptor)

            let linkDescriptor = FetchDescriptor<LinkItem>(
                sortBy: [SortDescriptor(\.savedDate, order: .reverse)]
            )
            allLinks = try context.fetch(linkDescriptor)
            updateFilteredLinks()

        } catch {
            print("데이터 로드 실패: \(error)")
        }
    }

    func reloadAllData() {
        allLinks = []
        loadInitialData()
    }

    func updateFilteredLinks() {
        var links = allLinks

        // 카테고리 필터링
        if let selectedCategory = selectedCategory {
            links = links.filter { link in
                link.categories?.contains { $0.id == selectedCategory.id } ?? false
            }
        }

        // 정렬 적용
        switch sortOption {
        case .dateNewest:
            links.sort { $0.savedDate > $1.savedDate }
        case .dateOldest:
            links.sort { $0.savedDate < $1.savedDate }
        case .titleAtoZ:
            links.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .titleZtoA:
            links.sort { $0.title.localizedCompare($1.title) == .orderedDescending }
        }

        filteredLinks = links
    }

    // 카테고리 저장
    func saveCategory(
        name: String,
        icon: String,
        colorHex: String = "#6C757D"
    ) {
        guard let context = modelContext else { return }

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        // 중복 이름 체크
        let existingCategory = categories.first {
            $0.name.lowercased() == trimmedName.lowercased()
        }
        guard existingCategory == nil else {
            // 중복 알림은 View에서 처리
            return
        }

        let newCategory = CategoryItem(
            name: trimmedName,
            icon: icon,
            color: colorHex
        )
        context.insert(newCategory)

        do {
            try context.save()
            // 카테고리 목록 업데이트
            categories.append(newCategory)
            categories
                .sort {
                    ($0.createdDate ?? Date()) < ($1.createdDate ?? Date())
                }
        } catch {
            print("카테고리 저장 실패: \(error)")
        }
    }

    // 카테고리 삭제
    func deleteCategory(_ category: CategoryItem) {
        guard let context = modelContext else { return }

        context.delete(category)

        do {
            try context.save()
            // 로컬 배열에서도 제거
            categories.removeAll { $0.id == category.id }
            // 선택된 카테고리가 삭제된 경우 선택 해제
            if selectedCategory?.id == category.id {
                selectedCategory = nil
            }
            updateFilteredLinks()
        } catch {
            print("카테고리 삭제 실패: \(error)")
        }
    }

    // 링크 삭제
    func deleteLink(_ link: LinkItem) {
        guard let context = modelContext else { return }
        let linkID = link.id

        context.delete(link)

        do {
            try context.save()
            // 로컬 배열에서도 제거
            allLinks.removeAll { $0.id == linkID }
            updateFilteredLinks()
            Task { await SpotlightIndexingService().delete(linkId: linkID) }
        } catch {
            print("링크 삭제 실패: \(error)")
        }
    }

    // 앱 활성화 시 데이터 리프레시 (ShareExtension 사용 후 복귀 시)
    func refreshDataAfterExternalChange() {
        print("외부 변경 감지, 데이터 리프레시 중...")
        // 강제 리프레시를 위해 모든 데이터를 다시 로드
        allLinks = []
        loadInitialData()
        lastRefreshDate = Date()
    }

    // 앱 활성화 시 데이터 리프레시 (안전장치)
    func refreshDataIfNeeded() {
        let now = Date()
        let refreshInterval: TimeInterval = 30 // 30초

        // 마지막 리프레시로부터 30초가 지났거나 처음인 경우에만 리프레시
        if lastRefreshDate == nil || now.timeIntervalSince(lastRefreshDate!) > refreshInterval {
            print("앱 활성화로 인한 데이터 리프레시...")
            reloadAllData()
            lastRefreshDate = now
        }
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDataReset),
            name: .dataReset,
            object: nil
        )
    }

    @objc private func handleDataReset() {
        refreshData()
    }

    func refreshData() {
        guard let context = modelContext else { return }

        do {
            // 모든 링크 다시 로드
            let linkDescriptor = FetchDescriptor<LinkItem>(
                sortBy: [SortDescriptor(\.savedDate, order: .reverse)]
            )
            allLinks = try context.fetch(linkDescriptor)

            // 카테고리 다시 로드
            let categoryDescriptor = FetchDescriptor<CategoryItem>(
                sortBy: [SortDescriptor(\.createdDate, order: .forward)]
            )
            categories = try context.fetch(categoryDescriptor)

            // 필터링된 링크 업데이트
            updateFilteredLinks()

        } catch {
            print("데이터 리프레시 중 오류: \(error)")
        }
    }
}

extension Notification.Name {
    static let dataReset = Notification.Name("DataResetNotification")
}
