//
//  HomeState.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI
import SwiftData

class HomeState: ObservableObject {
    // Sheet 관리
    @Published var activeSheet: HomeSheetType?
    @Published var showingDuplicateAlert = false
    @Published var showingDeleteConfirmation = false
    @Published var showingNoSelectionAlert = false

    // 편집 모드 상태
    @Published var isEditing = false
    @Published var selectedLinks = Set<LinkItem>()

    private var shareCompletedObserver: NSObjectProtocol?

    init() {
        setupNotifications()
    }

    deinit {
        if let observer = shareCompletedObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func setupNotifications() {
        shareCompletedObserver = NotificationCenter.default.addObserver(
            forName: .shareCompleted,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            // 공유 완료 시 편집 모드 종료
            DispatchQueue.main.async {
                if self?.isEditing == true {
                    self?.toggleEditingMode()
                }
            }
        }
    }

    // 링크 선택 토글
    func toggleLinkSelection(_ link: LinkItem) {
        if selectedLinks.contains(link) {
            selectedLinks.remove(link)
        } else {
            selectedLinks.insert(link)
        }
    }

    // 모든 선택 해제
    func clearSelection() {
        selectedLinks.removeAll()
    }

    // 편집 모드 토글
    func toggleEditingMode() {
        if isEditing {
            clearSelection()
        }
        isEditing.toggle()
    }

    // 선택된 링크들 삭제 (삭제 로직은 ViewModel에서 처리)
    func prepareDeleteSelectedLinks() -> [LinkItem] {
        return Array(selectedLinks)
    }

    // 삭제 완료 후 정리
    func completeDelete() {
        clearSelection()
        isEditing = false
    }
}
