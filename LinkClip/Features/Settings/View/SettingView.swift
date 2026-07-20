//
//  SettingView.swift
//  LinkClip
//
//  Created by 심관혁 on 4/8/25.
//

import MessageUI
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

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
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var backupDocument = LinkClipBackupDocument()

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

                    Button {
                        exportBackup()
                    } label: {
                        Label("백업 내보내기", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showingImporter = true
                    } label: {
                        Label("백업 가져오기", systemImage: "square.and.arrow.down")
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
            .fileExporter(
                isPresented: $showingExporter,
                document: backupDocument,
                contentType: .json,
                defaultFilename: "LinkClip-Backup"
            ) { result in
                showToast(result.isSuccess ? "백업을 내보냈습니다." : "백업을 내보내지 못했습니다.")
            }
            .fileImporter(isPresented: $showingImporter, allowedContentTypes: [.json]) { result in
                importBackup(result)
            }
            .toast(isShowing: $showingToast, message: toastMessage)
        }
    }

    private func exportBackup() {
        do {
            let categories = try modelContext.fetch(FetchDescriptor<CategoryItem>())
            let links = try modelContext.fetch(FetchDescriptor<LinkItem>())
            let favorites = UserDefaults.shared.favoriteLinkIDs
            let backup = LinkClipBackup(
                categories: categories.map {
                    .init(id: $0.id, name: $0.name, icon: $0.icon, color: $0.color, createdDate: $0.createdDate)
                },
                links: links.map {
                    .init(
                        url: $0.url,
                        title: $0.title,
                        personalMemo: $0.personalMemo,
                        savedDate: $0.savedDate,
                        categoryIDs: $0.categories?.map(\.id) ?? [],
                        metaDescription: $0.metaDescription,
                        imageURL: $0.imageURL,
                        siteName: $0.siteName,
                        faviconURL: $0.faviconURL,
                        isFavorite: favorites.contains($0.id)
                    )
                },
                categoryOrder: UserDefaults.shared.categoryOrder
            )
            backupDocument = try LinkClipBackupDocument(backup: backup)
            showingExporter = true
        } catch {
            showToast("백업을 만들지 못했습니다.")
        }
    }

    private func importBackup(_ result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let accessing = url.startAccessingSecurityScopedResource()
            defer { if accessing { url.stopAccessingSecurityScopedResource() } }
            let backup = try JSONDecoder().decode(LinkClipBackup.self, from: Data(contentsOf: url))

            let storedCategories = try modelContext.fetch(FetchDescriptor<CategoryItem>())
            var categoriesByID = Dictionary(uniqueKeysWithValues: storedCategories.map { ($0.id, $0) })
            for item in backup.categories where categoriesByID[item.id] == nil {
                if let existing = storedCategories.first(where: {
                    $0.name.localizedCaseInsensitiveCompare(item.name) == .orderedSame
                }) {
                    categoriesByID[item.id] = existing
                    continue
                }
                let category = CategoryItem(name: item.name, icon: item.icon, color: item.color)
                category.id = item.id
                category.createdDate = item.createdDate
                modelContext.insert(category)
                categoriesByID[item.id] = category
            }

            let storedLinks = try modelContext.fetch(FetchDescriptor<LinkItem>())
            var linksByURL = Dictionary(uniqueKeysWithValues: storedLinks.map { ($0.url, $0) })
            var favoriteIDs = UserDefaults.shared.favoriteLinkIDs
            for item in backup.links {
                let link = linksByURL[item.url] ?? LinkItem(url: item.url, title: item.title)
                if linksByURL[item.url] == nil {
                    modelContext.insert(link)
                    linksByURL[item.url] = link
                }
                link.title = item.title
                link.personalMemo = item.personalMemo
                link.savedDate = item.savedDate
                link.categories = item.categoryIDs.compactMap { categoriesByID[$0] }
                link.metaDescription = item.metaDescription
                link.imageURL = item.imageURL
                link.siteName = item.siteName
                link.faviconURL = item.faviconURL
                if item.isFavorite { favoriteIDs.insert(link.id) }
            }

            try modelContext.save()
            UserDefaults.shared.favoriteLinkIDs = favoriteIDs
            UserDefaults.shared.categoryOrder = backup.categoryOrder.compactMap { categoriesByID[$0]?.id }
            NotificationCenter.default.post(name: .dataReset, object: nil)
            showToast("백업을 가져왔습니다.")
        } catch {
            showToast("올바른 LinkClip 백업 파일이 아닙니다.")
        }
    }

    private func showToast(_ message: String) {
        toastMessage = message
        withAnimation { showingToast = true }
    }

    private func resetAllData() async {
        do {
            let fetchDescriptor = FetchDescriptor<LinkItem>()
            let items = try modelContext.fetch(fetchDescriptor)

            for item in items {
                modelContext.delete(item)
            }

            try modelContext.save()
            UserDefaults.shared.favoriteLinkIDs = []
            UserDefaults.shared.removeAllSummaryRecords()

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

private struct LinkClipBackup: Codable {
    let version = 1
    let categories: [BackupCategory]
    let links: [BackupLink]
    let categoryOrder: [UUID]

    private enum CodingKeys: String, CodingKey {
        case version, categories, links, categoryOrder
    }
}

private struct BackupCategory: Codable {
    let id: UUID
    let name: String
    let icon: String
    let color: String?
    let createdDate: Date?
}

private struct BackupLink: Codable {
    let url: String
    let title: String
    let personalMemo: String?
    let savedDate: Date
    let categoryIDs: [UUID]
    let metaDescription: String?
    let imageURL: String?
    let siteName: String?
    let faviconURL: String?
    let isFavorite: Bool
}

private struct LinkClipBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var data = Data()

    init() {}

    init(backup: LinkClipBackup) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        data = try encoder.encode(backup)
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}

private extension Result {
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
}

#Preview {
    SettingView()
}
