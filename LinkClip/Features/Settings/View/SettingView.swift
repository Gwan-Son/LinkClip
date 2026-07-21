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
import UserNotifications

struct SettingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @State private var isReindexing: Bool = false
    @State private var isReloadingThumbnails: Bool = false

    @State private var showingMailView: Bool = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil

    // 토스트 메시지 상태
    @State private var showingToast: Bool = false
    @State private var toastMessage: String = ""
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var backupDocument = LinkClipBackupDocument()
    @State private var showingOnboarding = false
    @State private var usage = UserDefaults.shared.summaryUsage
    @State private var summaryServiceAvailable: Bool?
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var defaultSortOption = SortOption(
        rawValue: UserDefaults.shared.defaultSortOptionRawValue
    ) ?? .dateNewest
    @AppStorage(
        UserDefaults.Keys.appearance,
        store: UserDefaults.shared
    ) private var appearance = AppAppearance.system

    // 앱 정보
    private let appVersion =
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.3"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack(spacing: 14) {
                        Image("SettingImage")
                            .resizable()
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("LinkClip")
                                .font(.title3.bold())
                            Text("나만의 링크 보관함")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(versionDescription)
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .padding(.vertical, 10)
                }

                Section {
                    LabeledContent {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(summaryServiceAvailable == false ? Color.red : Color.green)
                                .frame(width: 7, height: 7)
                            Text(summaryServiceStatus)
                        }
                        .foregroundStyle(.secondary)
                    } label: {
                        Label("요약 서비스", systemImage: "sparkles")
                    }

                    LabeledContent {
                        Text(usage.map { "\($0.remainingRequests)회" } ?? "-")
                            .foregroundStyle(.secondary)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Label("오늘 남은 요약", systemImage: "gauge.with.dots.needle.33percent")
                            if let usageResetDescription {
                                Text(usageResetDescription)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Button(action: openNotificationSettings) {
                        LabeledContent {
                            Text(notificationStatusDescription)
                                .foregroundStyle(.secondary)
                        } label: {
                            Label("요약·읽기 알림", systemImage: "bell")
                        }
                    }
                } header: {
                    Text("AI 요약")
                } footer: {
                    Text("요약을 위해 링크 URL과 웹페이지 내용이 LinkClip 요약 서버로 전송됩니다.")
                }

                Section("사용 환경") {
                    Picker("기본 정렬", selection: $defaultSortOption) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.displayName).tag(option)
                        }
                    }
                    .onChange(of: defaultSortOption) { _, option in
                        UserDefaults.shared.defaultSortOptionRawValue = option.rawValue
                        NotificationCenter.default.post(name: .sortOptionChanged, object: nil)
                    }

                    Picker(selection: $appearance) {
                        ForEach(AppAppearance.allCases) { appearance in
                            Text(appearance.displayName).tag(appearance)
                        }
                    } label: {
                        Label("모양", systemImage: "circle.lefthalf.filled")
                    }
                }

                Section(LocalizedStringResource("manage_data", defaultValue: "데이터 관리")) {
                    Button(action: exportBackup) {
                        Label("백업 내보내기", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showingImporter = true
                    } label: {
                        Label("백업 가져오기", systemImage: "square.and.arrow.down")
                    }

                    NavigationLink {
                        AdvancedDataManagementView(
                            isReindexing: $isReindexing,
                            isReloadingThumbnails: $isReloadingThumbnails,
                            onReindex: reindexAll,
                            onReloadThumbnails: reloadThumbnails,
                            onReset: resetAllData
                        )
                    } label: {
                        Label("고급 데이터 관리", systemImage: "wrench.and.screwdriver")
                    }
                }

                Section("도움말") {
                    Button {
                        showingOnboarding = true
                    } label: {
                        Label("앱 사용 방법", systemImage: "questionmark.circle")
                    }

                    Button(action: contactSupport) {
                        HStack {
                            Label("문의하기", systemImage: "envelope")
                            Spacer()
                            if !MFMailComposeViewController.canSendMail() {
                                Text("이메일 주소 복사")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Link(
                        destination: URL(
                            string:
                                "https://raw.githubusercontent.com/Gwan-Son/LinkClip/refs/heads/main/privacy/privacy.md"
                        )!
                    ) {
                        Label("개인정보 처리방침", systemImage: "hand.raised")
                    }

                    Link(
                        destination: URL(
                            string:
                                "https://raw.githubusercontent.com/Gwan-Son/LinkClip/refs/heads/main/privacy/service.md"
                        )!
                    ) {
                        Label("이용약관", systemImage: "doc.text")
                    }

                    Link(destination: URL(string: "https://apps.apple.com/app/id6744954526?action=write-review")!) {
                        Label("앱 평가하기", systemImage: "star")
                    }
                }

                Section {
                    Text(copyrightDescription)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                }
            }
            .tint(.mainColor)
            .navigationTitle(String(localized: "설정"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "완료")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingMailView) {
                MailView(
                    result: $mailResult, subjects: String(localized: "LinkClip 앱 문의"),
                    messageBody: "앱 버전: \(appVersion)")
            }
            .fullScreenCover(isPresented: $showingOnboarding) {
                OnboardingView(showsCloseButton: true, offersStarterTags: false) {
                    showingOnboarding = false
                }
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
            .task { await refreshSettingsStatus() }
            .onChange(of: scenePhase) { _, phase in
                guard phase == .active else { return }
                Task { await refreshNotificationStatus() }
            }
        }
        .preferredColorScheme(appearance.colorScheme)
    }

    private var versionDescription: String {
        let format = String(localized: "버전 %@ (%@)", defaultValue: "버전 %1$@ (%2$@)")
        return String(format: format, locale: .current, appVersion, buildNumber)
    }

    private var copyrightDescription: String {
        String(
            format: String(localized: "© 2025–%@ LinkClip"),
            String(Calendar.current.component(.year, from: Date()))
        )
    }

    private var summaryServiceStatus: LocalizedStringKey {
        switch summaryServiceAvailable {
        case true: "정상"
        case false: "연결 확인 필요"
        case nil: "확인 중"
        }
    }

    private var usageResetDescription: String? {
        guard let resetAt = usage?.resetAt,
              let date = ISO8601DateFormatter().date(from: resetAt) else { return nil }
        return String(
            format: String(localized: "%@에 초기화"),
            date.formatted(date: .omitted, time: .shortened)
        )
    }

    private var notificationStatusDescription: LocalizedStringKey {
        switch notificationStatus {
        case .authorized, .provisional, .ephemeral: "켜짐"
        case .denied: "꺼짐"
        case .notDetermined: "설정 필요"
        @unknown default: "확인 필요"
        }
    }

    private func refreshSettingsStatus() async {
        await refreshNotificationStatus()
        do {
            usage = try await SummaryAPI.refreshUsage()
            summaryServiceAvailable = true
        } catch {
            usage = UserDefaults.shared.summaryUsage
            summaryServiceAvailable = false
        }
    }

    private func refreshNotificationStatus() async {
        notificationStatus = await UNUserNotificationCenter.current()
            .notificationSettings().authorizationStatus
    }

    private func openNotificationSettings() {
        if notificationStatus == .notDetermined {
            Task {
                await PushNotificationService.enable()
                notificationStatus = await UNUserNotificationCenter.current()
                    .notificationSettings().authorizationStatus
            }
            return
        }
        guard let url = URL(string: UIApplication.openNotificationSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    private func contactSupport() {
        if MFMailComposeViewController.canSendMail() {
            showingMailView = true
        } else {
            UIPasteboard.general.string = "id1593572580@gmail.com"
            showToast("이메일 주소 복사")
        }
    }

    private func exportBackup() {
        do {
            let categories = try modelContext.fetch(FetchDescriptor<CategoryItem>())
            let links = try modelContext.fetch(FetchDescriptor<LinkItem>())
            let favorites = UserDefaults.shared.favoriteLinkIDs
            let readIDs = UserDefaults.shared.readLinkIDs
            let readLaterIDs = UserDefaults.shared.readLaterLinkIDs
            let reminderDates = UserDefaults.shared.linkReminderDates
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
                        isFavorite: favorites.contains($0.id),
                        isRead: readIDs.contains($0.id),
                        isReadLater: readLaterIDs.contains($0.id),
                        reminderDate: reminderDates[$0.id]
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
            var readIDs = UserDefaults.shared.readLinkIDs
            var readLaterIDs = UserDefaults.shared.readLaterLinkIDs
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
                if item.isRead == true { readIDs.insert(link.id) }
                if item.isReadLater == true { readLaterIDs.insert(link.id) }
                if let reminderDate = item.reminderDate, reminderDate > Date() {
                    Task {
                        try? await ReadingReminderService.schedule(
                            linkID: link.id,
                            title: link.title,
                            date: reminderDate
                        )
                    }
                }
            }

            try modelContext.save()
            UserDefaults.shared.favoriteLinkIDs = favoriteIDs
            UserDefaults.shared.readLinkIDs = readIDs
            UserDefaults.shared.readLaterLinkIDs = readLaterIDs
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
            for category in try modelContext.fetch(FetchDescriptor<CategoryItem>()) {
                modelContext.delete(category)
            }

            try modelContext.save()
            UserDefaults.shared.favoriteLinkIDs = []
            UserDefaults.shared.readLinkIDs = []
            UserDefaults.shared.readLaterLinkIDs = []
            UserDefaults.shared.categoryOrder = []
            ReadingReminderService.cancelAll()
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

private struct AdvancedDataManagementView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var isReindexing: Bool
    @Binding var isReloadingThumbnails: Bool
    let onReindex: () async -> Void
    let onReloadThumbnails: () async -> Void
    let onReset: () async -> Void

    @State private var showingResetAlert = false

    private var isBusy: Bool { isReindexing || isReloadingThumbnails }

    var body: some View {
        List {
            Section {
                Button {
                    Task { await onReindex() }
                } label: {
                    Label(
                        isReindexing ? "Spotlight 재색인 중..." : "Spotlight 재색인",
                        systemImage: "magnifyingglass"
                    )
                }
                .disabled(isBusy)

                Button {
                    Task { await onReloadThumbnails() }
                } label: {
                    Label(
                        isReloadingThumbnails ? "썸네일 다시 로딩 중..." : "썸네일 다시 로딩",
                        systemImage: "photo"
                    )
                }
                .disabled(isBusy)
            } footer: {
                Text("검색 결과나 썸네일이 정상적으로 표시되지 않을 때만 사용하세요.")
            }

            Section {
                Button("모든 저장 데이터 삭제", role: .destructive) {
                    showingResetAlert = true
                }
            } header: {
                Text("위험 영역")
            } footer: {
                Text("저장한 링크, 태그, 요약, 읽기 상태와 알림이 모두 삭제됩니다.")
            }
        }
        .navigationTitle("고급 데이터 관리")
        .navigationBarTitleDisplayMode(.inline)
        .alert("모든 저장 데이터를 삭제할까요?", isPresented: $showingResetAlert) {
            Button("취소", role: .cancel) { }
            Button("모두 삭제", role: .destructive) {
                Task {
                    await onReset()
                    dismiss()
                }
            }
        } message: {
            Text("이 작업은 되돌릴 수 없습니다.")
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
    let isRead: Bool?
    let isReadLater: Bool?
    let reminderDate: Date?
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
