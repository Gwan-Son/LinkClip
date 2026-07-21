import NaturalLanguage
import SwiftData
import SwiftUI

struct LinkSummaryView: View {
    let link: LinkItem

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CategoryItem.createdDate) private var allCategories: [CategoryItem]
    @State private var record: SummaryRecord?
    @State private var errorMessage: String?
    @State private var isWorking = false
    @State private var showingResummaryConfirmation = false
    @State private var usage = UserDefaults.shared.summaryUsage

    private var currentRecord: SummaryRecord? {
        record?.linkID == link.id ? record : nil
    }

    private var retryUnavailable: Bool {
        currentRecord?.errorCode == "daily_limit" ||
        currentRecord?.errorCode == "server_daily_limit"
    }

    private var failureTitle: LocalizedStringKey {
        switch currentRecord?.errorCode {
        case "daily_limit": "오늘 요약 횟수를 모두 사용했습니다"
        case "server_daily_limit": "서버의 오늘 요약 한도가 소진됐습니다"
        case "queue_full": "요약 요청이 많습니다"
        default: "요약하지 못했습니다"
        }
    }

    private var failureDescription: String {
        switch currentRecord?.errorCode {
        case "daily_limit", "server_daily_limit":
            String(localized: "내일 다시 이용해주세요.")
        case "queue_full":
            String(localized: "잠시 후 다시 시도할 수 있습니다.")
        default:
            currentRecord?.error ?? String(localized: "잠시 후 다시 시도해주세요.")
        }
    }

    private var actionTitle: LocalizedStringKey {
        if currentRecord?.status == .failed { return "다시 시도" }
        return currentRecord == nil ? "요약 요청" : "다시 요약"
    }

    private var resetDescription: String? {
        guard let value = usage?.resetAt ?? currentRecord?.resetAt,
              let date = ISO8601DateFormatter().date(from: value) else { return nil }
        return String(
            format: String(localized: "%@에 초기화"),
            date.formatted(date: .abbreviated, time: .shortened)
        )
    }

    private var suggestedCategories: [CategoryItem] {
        guard let summary = currentRecord?.summary, !summary.isEmpty else { return [] }
        let assigned = Set((link.categories ?? []).map(\.id))
        let candidates = allCategories.filter { !assigned.contains($0.id) }
        let text = "\(link.title)\n\(summary.prefix(1500))"
        let language = NLLanguageRecognizer.dominantLanguage(for: text) ?? .english
        guard let embedding = NLEmbedding.sentenceEmbedding(for: language) else {
            return candidates.filter {
                text.localizedCaseInsensitiveContains($0.name)
            }.prefix(3).map { $0 }
        }
        return candidates
            .map { ($0, embedding.distance(between: text, and: $0.name)) }
            .filter { $0.1 < 1.3 }
            .sorted { $0.1 < $1.1 }
            .prefix(3)
            .map(\.0)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(link.title)
                            .font(.title2.bold())
                        Text(URL(string: link.url)?.host ?? link.url)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    HStack(spacing: 10) {
                        if let url = URL(string: link.url) {
                            ShareLink(item: url) {
                                Label("공유", systemImage: "square.and.arrow.up")
                            }
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(.primary)

                    Group {
                        switch currentRecord?.status {
                        case .completed:
                            if let summary = currentRecord?.summary {
                                VStack(alignment: .leading, spacing: 16) {
                                    Label("핵심 요약", systemImage: "sparkles")
                                        .font(.headline)
                                        .foregroundStyle(Color.mainColor)

                                    if let markdown = try? AttributedString(
                                        markdown: summary.replacingOccurrences(of: "~", with: "\\~"),
                                        options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
                                    ) {
                                        Text(markdown)
                                            .textSelection(.enabled)
                                            .lineSpacing(6)
                                    } else {
                                        Text(summary)
                                            .textSelection(.enabled)
                                            .lineSpacing(6)
                                    }

                                    ShareLink(item: summary) {
                                        Label("요약 공유", systemImage: "square.and.arrow.up")
                                    }
                                }
                            }
                        case .queued:
                            progress("요약 요청이 대기 중입니다.")
                        case .processing:
                            progress("로컬 AI가 요약하고 있습니다.")
                        case .pending:
                            progress("요약 요청을 접수하고 있습니다.")
                        case .failed:
                            ContentUnavailableView(
                                failureTitle,
                                systemImage: "exclamationmark.triangle",
                                description: Text(failureDescription)
                            )
                        case nil:
                            ContentUnavailableView(
                                "아직 요약이 없습니다",
                                systemImage: "sparkles",
                                description: Text("요약 요청은 하루 3회까지 사용할 수 있습니다.")
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if let remaining = usage?.remainingRequests ?? currentRecord?.remainingRequests {
                        VStack(alignment: .leading, spacing: 3) {
                            Label(
                                "오늘 요약 \(remaining)회 남음",
                                systemImage: "gauge.with.dots.needle.33percent"
                            )
                            if let resetDescription {
                                Text(resetDescription)
                                    .font(.caption)
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }

                    if let memo = link.personalMemo, !memo.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("나의 메모", systemImage: "note.text")
                                .font(.headline)
                            Text(memo)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    if let categories = link.categories, !categories.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("태그", systemImage: "tag")
                                .font(.headline)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(categories, id: \.id) { category in
                                        Text(category.name)
                                            .font(.subheadline)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 7)
                                            .background(Color(hex: category.safeColor).opacity(0.15))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    if !suggestedCategories.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("추천 태그", systemImage: "wand.and.stars")
                                .font(.headline)
                            Text("AI 요약을 바탕으로 추천했어요.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(suggestedCategories, id: \.id) { category in
                                        Button {
                                            addSuggestedCategory(category)
                                        } label: {
                                            Label(category.name, systemImage: "plus")
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(Color(hex: category.safeColor))
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(Color.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }

                    Button {
                        if currentRecord == nil || currentRecord?.status == .failed {
                            Task { await requestSummary(force: false) }
                        } else {
                            showingResummaryConfirmation = true
                        }
                    } label: {
                        Label(actionTitle, systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.mainColor)
                    .disabled(
                        retryUnavailable || isWorking || currentRecord?.status == .pending ||
                        currentRecord?.status == .queued || currentRecord?.status == .processing
                    )
                }
                .padding(20)
            }
            .background(Color.appBackground)
            .safeAreaInset(edge: .bottom) {
                if let url = URL(string: link.url) {
                    Link(destination: url) {
                        Label("원문 열기", systemImage: "arrow.up.right.square")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.mainColor)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.bar)
                }
            }
            .navigationTitle("AI 요약")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { dismiss() }
                }
            }
            .alert("요약 오류", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("확인", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .confirmationDialog(
                "요약을 다시 요청할까요?",
                isPresented: $showingResummaryConfirmation,
                titleVisibility: .visible
            ) {
                Button("다시 요약") {
                    Task { await requestSummary(force: true) }
                }
                Button("취소", role: .cancel) {}
            } message: {
                Text("오늘 사용할 수 있는 요약 횟수가 1회 차감됩니다.")
            }
            .task(id: link.id) {
                record = nil
                errorMessage = nil
                await refreshUsage()
                await pollUntilFinished()
            }
        }
    }

    private func progress(_ message: LocalizedStringKey) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                ProgressView().tint(Color.mainColor)
                Text(message)
                    .foregroundStyle(.secondary)
            }
            ForEach([0.92, 0.78, 0.58], id: \.self) { width in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.primary.opacity(0.08))
                    .frame(maxWidth: .infinity)
                    .frame(height: 12)
                    .scaleEffect(x: width, anchor: .leading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    @MainActor
    private func requestSummary(force: Bool) async {
        isWorking = true
        defer { isWorking = false }
        do {
            await AppAttestManager.shared.prepareSession()
            await PushNotificationService.enable()
            if force {
                record = try await SummaryAPI.submit(linkID: link.id, url: link.url, force: true)
            } else {
                SummaryAPI.markPending(linkID: link.id)
                record = try await SummaryAPI.sync(linkID: link.id, url: link.url)
            }
            await pollUntilFinished()
            await refreshUsage()
        } catch {
            errorMessage = error.localizedDescription
            record = UserDefaults.shared.summaryRecord(for: link.id)
        }
    }

    @MainActor
    private func pollUntilFinished() async {
        record = UserDefaults.shared.summaryRecord(for: link.id)
        while !Task.isCancelled &&
              (record?.status == .pending || record?.status == .queued || record?.status == .processing) {
            do {
                record = try await SummaryAPI.sync(linkID: link.id, url: link.url)
            } catch {
                errorMessage = error.localizedDescription
                return
            }
            guard record?.status == .queued || record?.status == .processing else { return }
            do {
                try await Task.sleep(for: .seconds(5))
            } catch {
                return
            }
        }
    }

    @MainActor
    private func refreshUsage() async {
        await AppAttestManager.shared.prepareSession()
        usage = (try? await SummaryAPI.refreshUsage()) ?? UserDefaults.shared.summaryUsage
    }

    private func addSuggestedCategory(_ category: CategoryItem) {
        link.categories = (link.categories ?? []) + [category]
        try? modelContext.save()
    }
}
