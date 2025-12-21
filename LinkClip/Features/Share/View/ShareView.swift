//
//  ShareView.swift
//  LinkClip
//
//  Created by 심관혁 on 3/11/25.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

// LinkClip 앱 테마 색상
extension Color {
    // Share Extension에서는 asset catalog 접근이 제한되므로 직접 색상 값 사용
    static let mainColor = Color(hex: "FFC277")  // MainColor: #FFC277
    static let backgroundColor = Color(hex: "170800")  // BackgroundColor: #170800
}

struct ShareView: View {
    @State private var title: String = ""
    @State private var personalMemo: String = ""
    @State private var url: URL?
    @State private var selectedCategories: Set<CategoryItem> = []

    // 저장완료 시 alert를 띄우기 위한 상태
    @State private var isSaved: Bool = false

    // 사이트 이름 추출을 위한 상태
    @State private var siteName: String? = nil
    @State private var thumbnailURL: String? = nil

    // Title
    var extensionTitle: String?

    // Extension Context를 전달받기 위한 프로퍼티
    var extensionContext: NSExtensionContext?

    // 카테고리 목록을 가져오기 위한 상태
    @State private var categories: [CategoryItem] = []

    // 이 뷰를 ShareExtension에서 사용할 수 있도록 초기화
    init(url: URL, extensionContext: NSExtensionContext?, extensionTitle: String?) {
        self._url = State(initialValue: url)
        self.extensionContext = extensionContext
        if extensionTitle != nil {
            // title이 존재하면 제목으로 설정
            self._title = State(initialValue: extensionTitle ?? "No title")
        } else {
            // URL의 호스트를 기본 제목으로 설정
            self._title = State(initialValue: url.host ?? "No title")
        }
    }

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 제목 입력
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil")
                                .foregroundColor(Color.mainColor)
                                .font(.system(size: 18, weight: .medium))
                            Text(LocalizedStringResource("제목", defaultValue: "제목"))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                        }

                        TextField(String(localized: "URL 제목을 입력하세요", defaultValue: "URL 제목을 입력하세요"), text: $title)
                            .font(.system(size: 16))
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.mainColor.opacity(0.2), lineWidth: 1)
                            )
                    }

                    // 카테고리 선택
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Image(systemName: "tag")
                                .foregroundColor(.mainColor)
                                .font(.system(size: 18, weight: .medium))
                            Text(LocalizedStringResource("카테고리", defaultValue: "카테고리"))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            Text(LocalizedStringResource("(여러 개 선택 가능)", defaultValue: "(여러 개 선택 가능)"))
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }

                        if categories.isEmpty {
                            Text(LocalizedStringResource("등록된 카테고리가 없습니다", defaultValue: "등록된 카테고리가 없습니다"))
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                            ForEach(categories) { category in
                                let color = Color(hex: category.safeColor)
                                let isSelected = selectedCategories.contains(category)

                                    CategoryChip(
                                        title: category.name,
                                        icon: category.icon,
                                        color: color,
                                        isSelected: isSelected
                                    ) {
                                        if isSelected {
                                            selectedCategories.remove(category)
                                        } else {
                                            selectedCategories.insert(category)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // 메모 입력
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "note.text")
                                .foregroundColor(.mainColor)
                                .font(.system(size: 18, weight: .medium))
                            Text(LocalizedStringResource("메모", defaultValue: "메모"))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            Text(LocalizedStringResource("(선택사항)", defaultValue: "(선택사항)"))
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }

                        ZStack(alignment: .topLeading) {
                            if personalMemo.isEmpty {
                                Text(LocalizedStringResource("링크에 대한 메모를 남겨보세요", defaultValue: "링크에 대한 메모를 남겨보세요"))
                                    .foregroundColor(.secondary.opacity(0.7))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 16)
                            }

                            TextEditor(text: $personalMemo)
                                .font(.system(size: 16))
                                .frame(minHeight: 100)
                                .padding(16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.mainColor.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // URL 정보
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "link")
                                .foregroundColor(.mainColor)
                                .font(.system(size: 18, weight: .medium))
                            Text(LocalizedStringResource("URL 정보", defaultValue: "URL 정보"))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                        }

                        Text(url?.absoluteString ?? "")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.mainColor.opacity(0.2), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
            .navigationTitle(LocalizedStringResource("URL 저장", defaultValue: "URL 저장"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(LocalizedStringResource("btn_cancel", defaultValue: "취소")) {
                        if let extensionContext {
                            extensionContext.completeRequest(returningItems: [], completionHandler: nil)
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        saveURL()
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                            Text(LocalizedStringResource("저장", defaultValue: "저장"))
                        }
                        .foregroundColor(.mainColor)
                        .font(.system(size: 16, weight: .semibold))
                    }
                }
            }
            .alert(isPresented: $isSaved) {
                Alert(
                    title: Text(LocalizedStringResource("alert_url_saved_title", defaultValue: "URL 저장됨")),
                    message: Text(
                        LocalizedStringResource(
                            "alert_url_saved_message", defaultValue: "URL이 성공적으로 저장되었습니다.")
                    ),
                    dismissButton: .default(
                        Text(LocalizedStringResource("btn_confirm", defaultValue: "확인")),
                        action: {
                            if let extensionContext {
                                extensionContext.completeRequest(returningItems: [], completionHandler: nil)
                            } else {
                                dismiss()
                            }
                        }
                    )
                )
            }
            .onAppear {
                loadCategories()
                // 메타데이터 추출 (썸네일 + 사이트 이름)
                if let url = url {
                    Task {
                        await extractMetadata(from: url)
                    }
                }
            }
        }
    }

    func loadCategories() {
        let context = SharedModelContainer.shared.container.mainContext

        do {
            let descriptor = FetchDescriptor<CategoryItem>()
            categories = try context.fetch(descriptor)
        } catch {
            print("카테고리 로드 중 오류 발생: \(error)")
            categories = []
        }
    }

    private func extractMetadata(from url: URL) async {
        do {
            // 썸네일 URL 가져오기
            if let thumbnail = try await ThumbnailService.shared.fetchThumbnailURL(from: url) {
                await MainActor.run {
                    thumbnailURL = thumbnail.absoluteString
                }
            }

            // 사이트 이름 가져오기
            let (data, _) = try await URLSession.shared.data(from: url)
            if let htmlString = String(data: data, encoding: .utf8) {
                // Open Graph title 찾기
                let ogTitlePattern = "<meta[^>]*property=[\"']og:title[\"'][^>]*content=[\"']([^\"']+)[\"']"
                let titlePattern = "<title[^>]*>([^<]+)</title>"

                var extractedSiteName: String? = nil

                if let ogTitle = extractContent(from: htmlString, pattern: ogTitlePattern) {
                    extractedSiteName = ogTitle
                } else if let title = extractContent(from: htmlString, pattern: titlePattern) {
                    extractedSiteName = title
                } else {
                    // 호스트 이름 사용
                    extractedSiteName = url.host
                }

                await MainActor.run {
                    siteName = extractedSiteName
                }
            }
        } catch {
            print("메타데이터 추출 실패: \(error.localizedDescription)")
        }
    }

    private func extractContent(from html: String, pattern: String) -> String? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let nsString = html as NSString
            let results = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))

            if let result = results.first, result.numberOfRanges > 1 {
                return nsString.substring(with: result.range(at: 1))
            }
        } catch {
            print("Regex error: \(error)")
        }
        return nil
    }

    private func saveURL() {
        guard let url = url else { return }

        let context = SharedModelContainer.shared.container.mainContext

        do {
            // 선택된 카테고리들을 실제 객체로 가져오기
            var categoriesToUse: [CategoryItem]? = nil
            if !selectedCategories.isEmpty {
                var foundCategories: [CategoryItem] = []
                for selectedCategory in selectedCategories {
                    let categoryID = selectedCategory.id
                    let descriptor = FetchDescriptor<CategoryItem>(
                        predicate: #Predicate { $0.id == categoryID })
                    if let foundCategory = try context.fetch(descriptor).first {
                        foundCategories.append(foundCategory)
                    }
                }
                categoriesToUse = foundCategories.isEmpty ? nil : foundCategories
            }

            let urlString = url.absoluteString
            // 중복 URL 여부 확인 후 upsert 처리
            var existingDescriptor = FetchDescriptor<LinkItem>(
                predicate: #Predicate { $0.url == urlString }
            )
            existingDescriptor.fetchLimit = 1
            let itemToIndex: LinkItem
            if let existing = try context.fetch(existingDescriptor).first {
                // 기존 항목 업데이트
                let newTitle = title.isEmpty ? (url.host ?? existing.title) : title
                existing.title = newTitle
                existing.personalMemo = personalMemo.isEmpty ? existing.personalMemo : personalMemo
                existing.categories = categoriesToUse
                // 메타데이터 업데이트 (새로 가져온 경우에만)
                if thumbnailURL != nil {
                    existing.imageURL = thumbnailURL
                    existing.siteName = siteName
                    existing.isMetadataLoaded = true
                    existing.metadataLoadDate = Date()
                }
                itemToIndex = existing
            } else {
                // 새 항목 삽입
                let savedURL = LinkItem(
                    url: urlString,
                    title: title.isEmpty ? (url.host ?? "제목 없음") : title,
                    personalMemo: personalMemo.isEmpty ? nil : personalMemo,
                    categories: categoriesToUse,
                    metaDescription: nil,
                    imageURL: thumbnailURL,
                    siteName: siteName,
                    faviconURL: nil,
                    isMetadataLoaded: thumbnailURL != nil,
                    metadataLoadDate: thumbnailURL != nil ? Date() : nil
                )
                context.insert(savedURL)
                itemToIndex = savedURL
            }
            try context.save()

            // 메인 앱에 데이터 변경 알림 (UserDefaults 방식)
            UserDefaults.shared.notifyDataChanged()

            // Spotlight 색인 (비동기)
            Task { await SpotlightIndexingService().index(link: itemToIndex) }

            isSaved = true
        } catch (let error) {
            print("URL 저장 중 오류 발생: \(error)")
            if error is ShareError {
                extensionContext?.cancelRequest(withError: error as! ShareError)
            } else {
                extensionContext?.cancelRequest(withError: ShareError.unknown)
            }
        }
    }
}

#Preview {
    ShareView(
        url: URL(string: "https://www.google.com")!, extensionContext: NSExtensionContext(),
        extensionTitle: nil)
}
