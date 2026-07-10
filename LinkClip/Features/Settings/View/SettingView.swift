//
//  SettingView.swift
//  LinkClip
//
//  Created by 심관혁 on 4/8/25.
//

import MessageUI
import SwiftData
import SwiftUI

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var isReindexing: Bool = false
    @State private var isReloadingThumbnails: Bool = false

    // 알림창 상태 관리
    @State private var showingResetAlert: Bool = false
    @State private var showingMailView: Bool = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil

    // 토스트 메시지 상태
    @State private var showingToast: Bool = false
    @State private var toastMessage: String = ""

    // 앱 정보
    private let appVersion =
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.3"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        NavigationStack {
            List {
                // 앱 정보 섹션
                Section {
                    HStack {
                        Image("SettingImage")
                            .resizable()
                            .cornerRadius(20)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.blue)
                            .padding(.trailing, 10)

                        VStack(alignment: .leading) {
                            Text("LinkClip")
                                .font(.headline)

                            Text(
                                {
                                    let format = String(localized: "버전 %@ (%@)", defaultValue: "버전 %1$@ (%2$@)")
                                    return String(format: format, locale: .current, appVersion, buildNumber)
                                }()
                            )
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // 데이터 관리 섹션
                Section(header: Text(LocalizedStringResource("manage_data", defaultValue: "데이터 관리"))) {
                    Button {
                        Task { await reindexAll() }
                    } label: {
                        HStack {
                            Image(
                                systemName: isReindexing
                                ? "arrow.triangle.2.circlepath.circle.fill" : "arrow.triangle.2.circlepath"
                            )
                            .foregroundColor(.blue)
                            Text(String(localized: isReindexing ? "Spotlight 재색인 중..." : "Spotlight 재색인"))
                        }
                    }

                    Button {
                        Task { await reloadThumbnails() }
                    } label: {
                        HStack {
                            Image(
                                systemName: isReloadingThumbnails
                                ? "photo.circle.fill" : "photo.circle"
                            )
                            .foregroundColor(.green)
                            Text(String(localized: isReloadingThumbnails ?
                                        LocalizedStringResource("썸네일 다시 로딩 중...", defaultValue: "썸네일 다시 로딩 중...") :
                                        LocalizedStringResource("썸네일 다시 로딩", defaultValue: "썸네일 다시 로딩")))
                        }
                    }

                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                            Text(LocalizedStringResource("reset_saved_url", defaultValue: "저장된 URL 초기화"))
                        }
                    }
                }

                // 지원 섹션
                Section(header: Text(LocalizedStringResource("support", defaultValue: "지원"))) {
                    Button {
                        if MFMailComposeViewController.canSendMail() {
                            showingMailView = true
                        } else {
                            // 메일을 보낼 수 없는 경우 클립보드에 이메일 주소 복사
                            UIPasteboard.general.string = "id1593572580@gmail.com"

                            // 토스트 메시지 표시
                            toastMessage = String(localized: "이메일 주소 복사")
                            withAnimation {
                                showingToast = true
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.blue)
                            Text(String(localized: "문의하기"))

                            Spacer()

                            if !MFMailComposeViewController.canSendMail() {
                                Text(String(localized: "이메일 주소 복사"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }

                    Link(
                        destination: URL(
                            string:
                                "https://raw.githubusercontent.com/Gwan-Son/LinkClip/refs/heads/main/privacy/privacy.md"
                        )!
                    ) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.blue)
                            Text(String(localized: "개인정보 처리방침"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    Link(
                        destination: URL(
                            string:
                                "https://raw.githubusercontent.com/Gwan-Son/LinkClip/refs/heads/main/privacy/service.md"
                        )!
                    ) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.blue)
                            Text(String(localized: "이용약관"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // 앱 정보 섹션
                Section(header: Text(String(localized: "정보"))) {
                    Link(destination: URL(string: "https://apps.apple.com/app/id6744954526?action=write-review")!) {
                        HStack {
                            Image(systemName: "star")
                                .foregroundColor(.yellow)
                            Text(String(localized: "앱 평가하기"))
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // 푸터 정보
                Section {
                    Text(String(localized: "@ 2025 Linkclip. All rights reserved."))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            }
            .tint(.blue)
            .navigationTitle(String(localized: "설정"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "완료")) {
                        dismiss()
                    }
                }
            }
            .alert(String(localized: "모든 URL을 삭제하시겠습니까?"), isPresented: $showingResetAlert) {
                Button(String(localized: "취소"), role: .cancel) {}
                Button(String(localized: "삭제"), role: .destructive) {
                    Task { await resetAllData() }
                }
            } message: {
                Text(String(localized: "이 작업은 되돌릴 수 없습니다."))
            }
            .sheet(isPresented: $showingMailView) {
                MailView(
                    result: $mailResult, subjects: String(localized: "LinkClip 앱 문의"),
                    messageBody: "앱 버전: \(appVersion)")
            }
            .toast(isShowing: $showingToast, message: toastMessage)
        }
    }

    private func resetAllData() async {
        do {
            let fetchDescriptor = FetchDescriptor<LinkItem>()
            let items = try modelContext.fetch(fetchDescriptor)

            for item in items {
                modelContext.delete(item)
            }

            try modelContext.save()

            await SpotlightIndexingService().deleteAll()

            // 데이터 리셋 알림 전송
            NotificationCenter.default.post(name: .dataReset, object: nil)

            // 초기화 완료 토스트 메시지
            toastMessage = "모든 URL이 초기화되었습니다.".localized()
            withAnimation {
                showingToast = true
            }
        } catch {
            print("데이터 초기화 중 오류 발생: \(error.localizedDescription)")
        }
    }

    private func reindexAll() async {
        await MainActor.run { isReindexing = true }
        defer { Task { await MainActor.run { isReindexing = false } } }

        let descriptor = FetchDescriptor<LinkItem>()
        do {
            let entries: [SpotlightEntry] = try await MainActor.run {
                let links = try modelContext.fetch(descriptor)
                return links.map { link in
                    SpotlightEntry(
                        id: link.id,
                        urlString: link.url,
                        title: link.title,
                        personalMemo: link.personalMemo,
                        metaDescription: link.metaDescription,
                        imageURL: link.imageURL,
                        siteName: link.siteName,
                        faviconURL: link.faviconURL,
                        savedDate: link.savedDate,
                        metadataLoadDate: link.metadataLoadDate,
                        categoryIds: link.categories?.map { $0.id }
                    )
                }
            }

            let spotlight: SpotlightIndexing = SpotlightIndexingService()
            await spotlight.deleteAll()
            await spotlight.indexAllEntries(entries)
            await MainActor.run {
                toastMessage = String(localized: "Spotlight 재색인이 완료되었습니다.")
                withAnimation { showingToast = true }
            }
        } catch {
            await MainActor.run {
                toastMessage = String(localized: "재색인 중 오류가 발생했습니다.")
                withAnimation { showingToast = true }
            }
        }
    }

    private func reloadThumbnails() async {
        await MainActor.run { isReloadingThumbnails = true }
        defer { Task { await MainActor.run { isReloadingThumbnails = false } } }

        do {
            // 썸네일이 없는 링크들 찾기
            let descriptor = FetchDescriptor<LinkItem>(
                predicate: #Predicate<LinkItem> { link in
                    link.imageURL == nil || link.siteName == nil
                }
            )
            let linksWithoutThumbnails = try modelContext.fetch(descriptor)

            guard !linksWithoutThumbnails.isEmpty else {
                await MainActor.run {
                    toastMessage = String(localized: "썸네일이 없는 링크가 없습니다.")
                    withAnimation { showingToast = true }
                }
                return
            }

            var successCount = 0

            // 각 링크에 대해 썸네일 로딩 시도
            for link in linksWithoutThumbnails {
                if let url = URL(string: link.url) {
                    do {
                        let metadata = try await ThumbnailService.shared.fetchMetadata(from: url)
                        await MainActor.run {
                            link.imageURL = metadata.imageURL?.absoluteString
                            link.siteName = metadata.siteName
                            link.metadataLoadDate = Date()
                            if metadata.imageURL != nil || metadata.siteName != nil {
                                successCount += 1
                            }
                        }
                    } catch {
                        print("썸네일 로딩 실패 - \(link.url): \(error)")
                    }
                }
            }

            // 변경사항 저장
            try modelContext.save()

            await MainActor.run {
                toastMessage = String(localized: "\(successCount)개의 썸네일을 다시 로딩했습니다.")
                withAnimation { showingToast = true }
            }

        } catch {
            await MainActor.run {
                toastMessage = String(localized: "썸네일 다시 로딩 중 오류가 발생했습니다.")
                withAnimation { showingToast = true }
            }
        }
    }
}

#Preview {
    SettingView()
}
