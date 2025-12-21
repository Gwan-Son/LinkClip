//
//  AddLinkView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/10/25.
//

import SwiftUI
import SwiftData

struct AddLinkView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CategoryItem.createdDate, order: .forward) private var categories: [CategoryItem]

    let onLinkAdded: ((String, String, String?, [CategoryItem]?, String?, String?) -> Void)?

    init(onLinkAdded: ((String, String, String?, [CategoryItem]?, String?, String?) -> Void)? = nil) {
        self.onLinkAdded = onLinkAdded
    }

    @State private var url: String = ""
    @State private var title: String = ""
    @State private var personalMemo: String = ""
    @State private var selectedCategories: Set<CategoryItem> = []
    @State private var showingAlert = false
    @State private var alertMessage = ""

    // 썸네일 관련 상태
    @State private var thumbnailURL: String? = nil
    @State private var isLoadingThumbnail: Bool = false
    @State private var siteName: String? = nil

    private let folderColors: [Color] = [
        Color(hex: "FF6B6B"), // 빨강
        Color(hex: "4ECDC4"), // 청록
        Color(hex: "45B7D1"), // 파랑
        Color(hex: "96CEB4"), // 민트
        Color(hex: "FFEAA7"), // 노랑
        Color(hex: "DDA0DD"), // 자주
        Color(hex: "98D8C8"), // 연두
        Color(hex: "F7DC6F"), // 금색
        Color(hex: "BB8FCE"), // 보라
        Color(hex: "85C1E9"), // 하늘
        Color(hex: "F8C471"), // 주황
        Color(hex: "82E0AA"), // 라임
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // URL 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("URL")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        HStack(spacing: 0) {
                            Text("https://")
                                .foregroundColor(.primary)
                                .font(.system(size: 16))
                            TextField("example.com", text: $url)
                                .font(.system(size: 16))
                                .onChange(of: url) { oldValue, newValue in
                                    // https://가 포함되어 있다면 제거 (중복 방지)
                                    if newValue.hasPrefix("https://") {
                                        url = String(newValue.dropFirst(8))
                                    }
                                }
                        }
                            .font(.system(size: 16))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onChange(of: url) { oldValue, newValue in
                                let trimmedURL = newValue.trimmingCharacters(in: .whitespaces)
                                // https://가 포함되어 있지 않으면 붙여서 완전한 URL 생성
                                let fullURL = trimmedURL.hasPrefix("https://") ? trimmedURL : "https://" + trimmedURL

                                // URL이 유효하고 기본값이 아니면 썸네일 자동 로드
                                if let url = URL(string: fullURL),
                                   url.scheme != nil, url.host != nil,
                                   trimmedURL.isEmpty == false {
                                    Task {
                                        await loadThumbnail(from: url)
                                    }
                                } else if trimmedURL.isEmpty {
                                    // URL이 비어있으면 썸네일 초기화
                                    thumbnailURL = nil
                                    siteName = nil
                                }
                            }
                    }

                    // 썸네일 미리보기
                    if isLoadingThumbnail || thumbnailURL != nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("미리보기")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)

                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 120)

                                if isLoadingThumbnail {
                                    ProgressView("썸네일 로딩 중...")
                                        .progressViewStyle(.circular)
                                } else if let thumbnailURL = thumbnailURL, let url = URL(string: thumbnailURL) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        case .failure:
                                            VStack(spacing: 8) {
                                                Image(systemName: "photo")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.secondary)
                                                Text("썸네일 로드 실패")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }

                                // 사이트 이름 표시
                                if let siteName = siteName {
                                    VStack {
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Text(siteName)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.white)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(Color.black.opacity(0.6))
                                                .cornerRadius(6)
                                                .padding(8)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 제목 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("제목")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        TextField("링크 제목을 입력하세요", text: $title)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // 메모 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("메모 (선택사항)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        TextEditor(text: $personalMemo)
                            .font(.system(size: 16))
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // 카테고리 선택
                    VStack(alignment: .leading, spacing: 16) {
                        Text("카테고리")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        if categories.isEmpty {
                            Text("등록된 카테고리가 없습니다")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                                ForEach(categories.indices, id: \.self) { index in
                                    let category = categories[index]
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
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("링크 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveLink()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                    .disabled(url.trimmingCharacters(in: .whitespaces).isEmpty ||
                             title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("알림", isPresented: $showingAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func loadThumbnail(from url: URL) async {
        await MainActor.run {
            isLoadingThumbnail = true
            thumbnailURL = nil
            siteName = nil
        }

        do {
            // 썸네일 URL 가져오기
            if let thumbnail = try await ThumbnailService.shared.fetchThumbnailURL(from: url) {
                await MainActor.run {
                    thumbnailURL = thumbnail.absoluteString
                }
            }

            // 사이트 이름 가져오기 (HTML 파싱)
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
                    // 사이트 이름을 제목으로 자동 입력 (제목이 비어있고, 메모가 비어있는 경우에만)
                    if title.isEmpty && personalMemo.isEmpty {
                        title = extractedSiteName ?? ""
                    }
                }
            }
        } catch {
            print("썸네일 로드 실패: \(error.localizedDescription)")
        }

        await MainActor.run {
            isLoadingThumbnail = false
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

    private func saveLink() {
        let trimmedURL = url.trimmingCharacters(in: .whitespaces)
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedMemo = personalMemo.trimmingCharacters(in: .whitespaces)

        guard !trimmedURL.isEmpty && trimmedURL != "https://" else {
            alertMessage = "URL을 입력해주세요."
            showingAlert = true
            return
        }

        guard !trimmedTitle.isEmpty else {
            alertMessage = "제목을 입력해주세요."
            showingAlert = true
            return
        }

        // https://가 포함되어 있지 않으면 붙여서 완전한 URL 생성
        let fullURL = trimmedURL.hasPrefix("https://") ? trimmedURL : "https://" + trimmedURL

        // URL 유효성 검사
        guard URL(string: fullURL) != nil else {
            alertMessage = "올바른 URL 형식을 입력해주세요."
            showingAlert = true
            return
        }

        let memo = trimmedMemo.isEmpty ? nil : trimmedMemo
        let selectedCategoriesArray = selectedCategories.isEmpty ? nil : Array(selectedCategories)

        let newLink = LinkItem(
            url: fullURL,
            title: trimmedTitle,
            personalMemo: memo,
            categories: selectedCategoriesArray,
            metaDescription: nil,
            imageURL: thumbnailURL,
            siteName: siteName,
            faviconURL: nil,
            isMetadataLoaded: thumbnailURL != nil,
            metadataLoadDate: thumbnailURL != nil ? Date() : nil
        )

        modelContext.insert(newLink)

        do {
            try modelContext.save()

            // HomeViewModel에 새로운 링크 알림
            onLinkAdded?(fullURL, trimmedTitle, memo, selectedCategoriesArray, thumbnailURL, siteName)

            print("링크 저장 성공: \(trimmedTitle)")
            dismiss()
        } catch {
            alertMessage = "링크 저장에 실패했습니다. 다시 시도해주세요."
            showingAlert = true
            print("링크 저장 실패: \(error)")
        }
    }
}

// MARK: - 링크 수정 화면

struct LinkEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \CategoryItem.createdDate, order: .forward) private var categories: [CategoryItem]

    let link: LinkItem
    let onLinkUpdated: ((LinkItem) -> Void)?

    init(link: LinkItem, onLinkUpdated: ((LinkItem) -> Void)? = nil) {
        self.link = link
        self.onLinkUpdated = onLinkUpdated
        _url = State(initialValue: link.url)
        _title = State(initialValue: link.title)
        _personalMemo = State(initialValue: link.personalMemo ?? "")
        _selectedCategories = State(initialValue: Set(link.categories ?? []))
        _thumbnailURL = State(initialValue: link.imageURL)
        _siteName = State(initialValue: link.siteName)
    }

    @State private var url: String
    @State private var title: String
    @State private var personalMemo: String
    @State private var selectedCategories: Set<CategoryItem>
    @State private var showingAlert = false
    @State private var alertMessage = ""

    // 썸네일 관련 상태
    @State private var thumbnailURL: String?
    @State private var isLoadingThumbnail: Bool = false
    @State private var siteName: String?

    private let folderColors: [Color] = [
        Color(hex: "FF6B6B"), // 빨강
        Color(hex: "4ECDC4"), // 청록
        Color(hex: "45B7D1"), // 파랑
        Color(hex: "96CEB4"), // 민트
        Color(hex: "FFEAA7"), // 노랑
        Color(hex: "DDA0DD"), // 자주
        Color(hex: "98D8C8"), // 연두
        Color(hex: "F7DC6F"), // 금색
        Color(hex: "BB8FCE"), // 보라
        Color(hex: "85C1E9"), // 하늘
        Color(hex: "F8C471"), // 주황
        Color(hex: "82E0AA"), // 라임
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // URL 정보 (수정 불가)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("URL")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        Text(url)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // 썸네일 미리보기 (기존 썸네일 표시)
                    if thumbnailURL != nil || isLoadingThumbnail {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("썸네일")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)

                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.1))
                                    .frame(height: 120)

                                if isLoadingThumbnail {
                                    ProgressView("썸네일 로딩 중...")
                                        .progressViewStyle(.circular)
                                } else if let thumbnailURL = thumbnailURL, let url = URL(string: thumbnailURL) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(height: 120)
                                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                        case .failure:
                                            VStack(spacing: 8) {
                                                Image(systemName: "photo")
                                                    .font(.system(size: 24))
                                                    .foregroundColor(.secondary)
                                                Text("썸네일 로드 실패")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // 제목 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("제목")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        TextField("링크 제목을 입력하세요", text: $title)
                            .font(.system(size: 16))
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // 메모 입력
                    VStack(alignment: .leading, spacing: 8) {
                        Text("메모 (선택사항)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        TextEditor(text: $personalMemo)
                            .font(.system(size: 16))
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }

                    // 카테고리 선택
                    VStack(alignment: .leading, spacing: 16) {
                        Text("카테고리")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)

                        if categories.isEmpty {
                            Text("등록된 카테고리가 없습니다")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                                ForEach(categories.indices, id: \.self) { index in
                                    let category = categories[index]
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
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
            .navigationTitle("링크 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                    .foregroundColor(.secondary)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        updateLink()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.blue)
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("알림", isPresented: $showingAlert) {
                Button("확인", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func updateLink() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedMemo = personalMemo.trimmingCharacters(in: .whitespaces)

        guard !trimmedTitle.isEmpty else {
            alertMessage = "제목을 입력해주세요."
            showingAlert = true
            return
        }

        do {
            // 기존 링크 업데이트
            link.title = trimmedTitle
            link.personalMemo = trimmedMemo.isEmpty ? nil : trimmedMemo
            link.categories = selectedCategories.isEmpty ? nil : Array(selectedCategories)

            // 썸네일 정보 업데이트 (필요시)
            if let thumbnailURL = thumbnailURL {
                link.imageURL = thumbnailURL
            }
            if let siteName = siteName {
                link.siteName = siteName
            }

            try modelContext.save()

            // 콜백 호출
            onLinkUpdated?(link)

            print("링크 수정 성공: \(trimmedTitle)")
            dismiss()
        } catch {
            alertMessage = "링크 수정에 실패했습니다. 다시 시도해주세요."
            showingAlert = true
            print("링크 수정 실패: \(error)")
        }
    }
}

#Preview {
    AddLinkView { url, title, memo, categories, imageURL, siteName in
        print("새 링크 추가: \(title)")
    }
}
