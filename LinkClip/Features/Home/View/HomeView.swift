//
//  HomeView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/7/25.
//

import SwiftData
import SwiftUI

enum HomeSheetType: Identifiable {
    case settings
    case addCategory
    case categoryManagement
    case addLink
    case editLink(LinkItem)
    case summary(LinkItem)
    case reminder(LinkItem)

    var id: String {
        switch self {
        case .settings: return "settings"
        case .addCategory: return "addCategory"
        case .categoryManagement: return "categoryManagement"
        case .addLink: return "addLink"
        case .editLink(let link): return "editLink-\(link.id)"
        case .summary(let link): return "summary-\(link.id)"
        case .reminder(let link): return "reminder-\(link.id)"
        }
    }
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = HomeViewModel()

    @StateObject private var state = HomeState()
    @State private var showingSearch = false
    @FocusState private var searchFocused: Bool

    private var areAllVisibleLinksSelected: Bool {
        !viewModel.filteredLinks.isEmpty &&
        Set(viewModel.filteredLinks).isSubset(of: state.selectedLinks)
    }

    private var searchSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)

            TextField(
                String(localized: "저장한 링크 검색", defaultValue: "저장한 링크 검색"),
                text: $viewModel.searchText
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .focused($searchFocused)

            if viewModel.isSearching {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .accessibilityLabel(
                    String(localized: "검색어 지우기", defaultValue: "검색어 지우기")
                )
            }
        }
        .padding(.horizontal, 14)
        .frame(height: 46)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
        .background(Color.appBackground)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HomeHeaderView(
                    isEditing: state.isEditing,
                    selectedCount: state.selectedLinks.count,
                    areAllSelected: areAllVisibleLinksSelected,
                    canEdit: !viewModel.filteredLinks.isEmpty,
                    onSearchTap: { toggleSearch() },
                    onEditingTap: { withAnimation { state.toggleEditingMode() } },
                    onSelectAllTap: { handleSelectAllToggle() },
                    onSettingsTap: { state.activeSheet = .settings }
                )

                ScrollView {
                    VStack(spacing: 0) {
                        if !state.isEditing && showingSearch {
                            searchSection
                        }

                        if !state.isEditing {
                            HomeCategoriesView(
                                viewModel: viewModel,
                                isEditing: state.isEditing,
                                onAddCategoryTap: { state.activeSheet = .addCategory },
                                onCategoryManagementTap: {
                                    state.activeSheet = .categoryManagement
                                }
                            )
                            .padding(.top, 10)
                        }

                        HomeLinksView(
                            viewModel: viewModel,
                            state: state,
                            onEditLink: { link in state.activeSheet = .editLink(link) },
                            onSummarize: { link in state.activeSheet = .summary(link) },
                            onReminder: { link in state.activeSheet = .reminder(link) }
                        )
                    }
                }
            }

            // 편집 모드 오버레이
            if state.isEditing {
                HomeEditToolbarView(
                    state: state,
                    onBatchAction: { handleBatchAction($0) },
                    onShareAttempt: { handleShareAttempt() },
                    onDeleteAttempt: { handleDeleteAttempt() }
                )
            }

        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            viewModel.setContext(modelContext)
            Task {
                await syncSummaries()
                await AppAttestManager.shared.prepareSession()
                _ = try? await SummaryAPI.refreshUsage()
            }
            handlePendingNotification()
        }
        .onDisappear {
            viewModel.searchText = ""
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // ShareExtension에서 데이터 변경이 있었는지 확인
                if UserDefaults.shared.consumeDataChange() {
                    print("ShareExtension에서 데이터 변경 감지 - 리프레시 실행")
                    viewModel.refreshDataAfterExternalChange()
                } else {
                    // 일반적인 앱 활성화 시에도 가벼운 리프레시 (30초 쿨다운 적용)
                    viewModel.refreshDataIfNeeded()
                }
                Task { await syncSummaries() }
                handlePendingNotification()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .summaryNotificationTapped)) { _ in
            handlePendingNotification()
        }
        .alert(LocalizedStringResource("중복된 카테고리 이름", defaultValue: "중복된 카테고리 이름"), isPresented: $state.showingDuplicateAlert) {
            Button(LocalizedStringResource("확인", defaultValue: "확인"), role: .cancel) { }
        } message: {
            Text(LocalizedStringResource("이미 존재하는 카테고리 이름입니다.\n다른 이름을 입력해주세요.", defaultValue: "이미 존재하는 카테고리 이름입니다.\n다른 이름을 입력해주세요."))
        }
        .alert(LocalizedStringResource("링크 삭제", defaultValue: "링크 삭제"), isPresented: $state.showingDeleteConfirmation) {
            Button(LocalizedStringResource("취소", defaultValue: "취소"), role: .cancel) { }
            Button(LocalizedStringResource("삭제", defaultValue: "삭제"), role: .destructive) {
                deleteSelectedLinks()
            }
        } message: {
            Text(String(localized: "%lld개의 링크를 삭제하시겠습니까?\n이 작업은 취소할 수 없습니다.", defaultValue: "%lld개의 링크를 삭제하시겠습니까?\n이 작업은 취소할 수 없습니다."))
        }
        .alert(LocalizedStringResource("삭제 불가", defaultValue: "삭제 불가"), isPresented: $state.showingNoSelectionAlert) {
            Button(LocalizedStringResource("확인", defaultValue: "확인"), role: .cancel) { }
        } message: {
            Text(LocalizedStringResource("삭제할 항목이 없습니다.\n링크를 선택한 후 다시 시도해주세요.", defaultValue: "삭제할 항목이 없습니다.\n링크를 선택한 후 다시 시도해주세요."))
        }
        .alert("링크 삭제", isPresented: Binding(
            get: { state.linkPendingDeletion != nil },
            set: { if !$0 { state.linkPendingDeletion = nil } }
        )) {
            Button("취소", role: .cancel) { state.linkPendingDeletion = nil }
            Button("삭제", role: .destructive) {
                if let link = state.linkPendingDeletion {
                    viewModel.deleteLink(link)
                }
                state.linkPendingDeletion = nil
            }
        } message: {
            Text("이 링크를 삭제하시겠습니까?")
        }
        .sheet(item: $state.activeSheet) { sheetType in
            HomeSheetView(
                sheetType: sheetType,
                viewModel: viewModel,
                onCategorySave: { name, icon, colorHex in
                    viewModel.saveCategory(name: name, icon: icon, colorHex: colorHex)
                },
                onLinkSave: {
                    viewModel.reloadAllData()
                }
            )
            .id(sheetType.id)
        }
        .toast(isShowing: $state.showingCopiedToast, message: "링크를 복사했습니다.")
    }

    // MARK: - Helper Functions

    private func toggleSearch() {
        withAnimation { showingSearch.toggle() }
        if showingSearch {
            Task { @MainActor in searchFocused = true }
        } else {
            searchFocused = false
            viewModel.searchText = ""
        }
    }

    private func syncSummaries() async {
        let links = (try? modelContext.fetch(FetchDescriptor<LinkItem>())) ?? []
        let pending = links.compactMap { link in
            UserDefaults.shared.summaryRecord(for: link.id) == nil ? nil : (link.id, link.url)
        }
        for (linkID, url) in pending {
            _ = try? await SummaryAPI.sync(linkID: linkID, url: url)
        }
    }

    private func handlePendingNotification() {
        guard let identifier = UserDefaults.shared.string(
            forKey: UserDefaults.Keys.pendingSummaryNotificationID
        ) else { return }
        let linkID = UUID(uuidString: identifier)
            ?? UserDefaults.shared.linkID(forSummaryIdentifier: identifier)
        guard let linkID else { return }
        let notificationType = UserDefaults.shared.string(
            forKey: UserDefaults.Keys.pendingNotificationType
        )
        UserDefaults.shared.removeObject(forKey: UserDefaults.Keys.pendingSummaryNotificationID)
        UserDefaults.shared.removeObject(forKey: UserDefaults.Keys.pendingNotificationType)
        guard let link = try? modelContext.fetch(
            FetchDescriptor<LinkItem>(predicate: #Predicate { $0.id == linkID })
        ).first else { return }
        if notificationType == "reading_reminder", let url = URL(string: link.url) {
            viewModel.markRead(link)
            ReadingReminderService.cancel(linkID: link.id)
            UIApplication.shared.open(url)
        } else {
            state.activeSheet = .summary(link)
        }
    }

    private func handleSelectAllToggle() {
        withAnimation {
            let visibleLinks = Set(viewModel.filteredLinks)
            if visibleLinks.isSubset(of: state.selectedLinks) {
                state.selectedLinks.subtract(visibleLinks)
            } else {
                state.selectedLinks.formUnion(visibleLinks)
            }
        }
    }

    private func handleShareAttempt() {
        guard !state.selectedLinks.isEmpty else { return }

        let shareText = createShareText(from: Array(state.selectedLinks))

        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )

        // 공유 완료 시 편집 모드 종료
        activityVC.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            if completed {
                // 공유 완료 시 편집 모드 종료를 위한 알림 전송
                NotificationCenter.default.post(name: .shareCompleted, object: nil)
            }
        }

        // iPad 대응
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            activityVC.popoverPresentationController?.sourceView = rootVC.view
            rootVC.present(activityVC, animated: true)
        }
    }

    private func handleBatchAction(_ action: HomeBatchAction) {
        let links = state.selectedLinks
        guard !links.isEmpty else { return }

        switch action {
        case .markRead:
            viewModel.setRead(links, enabled: true)
        case .markUnread:
            viewModel.setRead(links, enabled: false)
        case .addToReadLater:
            viewModel.setReadLater(links, enabled: true)
        case .removeFromReadLater:
            viewModel.setReadLater(links, enabled: false)
        case .addToFavorites:
            viewModel.setFavorite(links, enabled: true)
        case .removeFromFavorites:
            viewModel.setFavorite(links, enabled: false)
        }
        state.clearSelection()
    }

    private func handleDeleteAttempt() {
        if state.selectedLinks.isEmpty {
            state.showingNoSelectionAlert = true
        } else {
            state.showingDeleteConfirmation = true
        }
    }

    private func deleteSelectedLinks() {
        let linksToDelete = state.prepareDeleteSelectedLinks()
        for link in linksToDelete {
            viewModel.deleteLink(link)
        }
        state.completeDelete()
    }

    private func createShareText(from links: [LinkItem]) -> String {
        var shareText = String(localized: "LinkClip에서 공유해요!\n", defaultValue: "Shared from LinkClip!\n")

        for (index, link) in links.enumerated() {
            shareText += "\n\(index + 1). \(link.title)\n   \(link.url)"
        }

        return shareText
    }
}

extension Notification.Name {
    static let shareCompleted = Notification.Name("ShareCompletedNotification")
}

#Preview {
    HomeView()
}
