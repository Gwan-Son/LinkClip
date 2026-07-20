import SwiftUI

struct LinkSummaryView: View {
    let link: LinkItem

    @Environment(\.dismiss) private var dismiss
    @State private var record: SummaryRecord?
    @State private var errorMessage: String?
    @State private var isWorking = false

    private var currentRecord: SummaryRecord? {
        record?.linkID == link.id ? record : nil
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
                            Link(destination: url) {
                                Label("원문 열기", systemImage: "arrow.up.right.square")
                            }

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
                                        .foregroundStyle(Color(hex: "F2A65A"))

                                    if let markdown = try? AttributedString(
                                        markdown: summary,
                                        options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
                                    ) {
                                        Text(markdown)
                                            .textSelection(.enabled)
                                    } else {
                                        Text(summary)
                                            .textSelection(.enabled)
                                    }

                                    ShareLink(item: summary) {
                                        Label("요약 공유", systemImage: "square.and.arrow.up")
                                    }
                                }
                                .padding(18)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                        case .queued:
                            progress("요약 요청이 대기 중입니다.")
                        case .processing:
                            progress("로컬 AI가 요약하고 있습니다.")
                        case .pending:
                            progress("요약 요청을 접수하고 있습니다.")
                        case .failed:
                            ContentUnavailableView(
                                "요약하지 못했습니다",
                                systemImage: "exclamationmark.triangle",
                                description: Text(currentRecord?.error ?? "잠시 후 다시 시도해주세요.")
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

                    if let memo = link.personalMemo, !memo.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("나의 메모", systemImage: "note.text")
                                .font(.headline)
                            Text(memo)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(18)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
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
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    }

                    Button {
                        Task { await requestSummary(force: currentRecord != nil) }
                    } label: {
                        Label(currentRecord == nil ? "요약 요청" : "다시 요약", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: "F2A65A"))
                    .disabled(
                        isWorking || currentRecord?.status == .pending ||
                        currentRecord?.status == .queued || currentRecord?.status == .processing
                    )
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
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
            .task(id: link.id) {
                record = nil
                errorMessage = nil
                await pollUntilFinished()
            }
        }
    }

    private func progress(_ message: String) -> some View {
        HStack(spacing: 12) {
            ProgressView()
            Text(message)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
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
}
