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

    var id: String {
        switch self {
        case .settings: return "settings"
        case .addCategory: return "addCategory"
        case .categoryManagement: return "categoryManagement"
        case .addLink: return "addLink"
        case .editLink(let link): return "editLink-\(link.id)"
        }
    }
}

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var viewModel = HomeViewModel()

    @StateObject private var state = HomeState()

    // 최근 링크 섹션
    private var recentLinksSection: some View {
        VStack {
            HStack {
                Text(
                    viewModel.allLinks.isEmpty ?
                    LocalizedStringResource("저장된 링크가 없어요", defaultValue: "저장된 링크가 없어요") :
                    LocalizedStringResource("최근 저장한 링크에요", defaultValue: "최근 저장한 링크에요")
                )
                .font(.system(size: 18))
                .foregroundColor(.white)

                Spacer()

                Button {
                    state.activeSheet = .addLink
                } label: {
                    HStack {
                        Text(LocalizedStringResource("링크 추가", defaultValue: "링크 추가"))
                            .font(.system(size: 14))
                            .foregroundColor(.white)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    if viewModel.allLinks.isEmpty {
                        ForEach(0 ..< 3) { index in
                            LinkCardView(
                                isOnboarding: true,
                                onboardingIndex: index
                            )
                        }
                    } else {
                        ForEach(viewModel.allLinks.prefix(5)) { link in
                            LinkCardView(link: link)
                                .onTapGesture {
                                    if let url = URL(string: link.url) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 220)
        }
        .background(Color.background)
    }

    // 플로팅 편집 버튼
    private var floatingEditButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        state.toggleEditingMode()
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(state.isEditing ? Color.red : Color.blue)
                            .frame(width: 56, height: 56)
                            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)

                        Image(systemName: state.isEditing ? "xmark" : "checkmark.circle")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(state.isEditing ? .degrees(180) : .degrees(0))
                            .scaleEffect(state.isEditing ? 0.8 : 1.0)
                    }
                }
                .padding(.trailing, 20)
                .padding(.bottom, 60)
            }
        }
        .ignoresSafeArea(.keyboard)
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HomeHeaderView(
                    onCategoryManagementTap: { state.activeSheet = .categoryManagement },
                    onSettingsTap: { state.activeSheet = .settings }
                )

                if !state.isEditing {
                    recentLinksSection

                    HomeCategoriesView(
                        viewModel: viewModel,
                        isEditing: state.isEditing,
                        onAddCategoryTap: { state.activeSheet = .addCategory }
                    )
                    .padding(.top, 10)
                }

                HomeLinksView(
                    viewModel: viewModel,
                    state: state,
                    onEditLink: { link in state.activeSheet = .editLink(link) }
                )
            }

            // 편집 모드 오버레이
            if state.isEditing {
                HomeEditToolbarView(
                    state: state,
                    filteredLinks: viewModel.allLinks,
                    onSelectAllToggle: { handleSelectAllToggle() },
                    onShareAttempt: { handleShareAttempt() },
                    onDeleteAttempt: { handleDeleteAttempt() }
                )
            }

            // 플로팅 편집 버튼
            if !viewModel.filteredLinks.isEmpty {
                floatingEditButton
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.setContext(modelContext)
        }
        .onDisappear {
            viewModel.cleanupMemory()
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
            }
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
        .onAppear {
            viewModel.setContext(modelContext)
        }
        .sheet(item: $state.activeSheet) { sheetType in
            HomeSheetView(
                sheetType: sheetType,
                viewModel: viewModel,
                onCategorySave: { name, icon, colorHex in
                    viewModel.saveCategory(name: name, icon: icon, colorHex: colorHex)
                },
                onLinkSave: { url, title, memo, categories, imageURL, siteName in
                    viewModel.addLink(
                        url: url,
                        title: title,
                        personalMemo: memo,
                        categories: categories,
                        imageURL: imageURL.flatMap(URL.init)?.absoluteString,
                        siteName: siteName
                    )
                }
            )
        }
    }

    // MARK: - Helper Functions

    private func handleSelectAllToggle() {
        withAnimation {
            if state.selectedLinks.isEmpty {
                state.selectedLinks = Set(viewModel.allLinks)
            } else {
                state.clearSelection()
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
