//
//  LinkRowView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

struct LinkRow: View {
    let link: LinkItem
    var searchText = ""
    var isFavorite = false
    var isRead = false
    var isReadLater = false
    let onTap: () -> Void
    let onCopy: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    var onFavorite: () -> Void = {}
    var onRead: () -> Void = {}
    var onReadLater: () -> Void = {}
    var onReminder: (() -> Void)?
    var onSummary: (() -> Void)?
    @State private var summaryStatus: SummaryStatus?
    @State private var summaryText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                CachedAsyncImage(
                    primaryURL: link.faviconURL.flatMap(URL.init),
                    fallbackURL: link.imageURL.flatMap(URL.init)
                )
                .frame(width: 32, height: 32)
                .background(Color.primary.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
                .clipShape(RoundedRectangle(cornerRadius: 8))

                Text(siteLabel)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                if summaryStatus == .pending || summaryStatus == .queued || summaryStatus == .processing {
                    HStack(spacing: 5) {
                        ProgressView().controlSize(.mini)
                        Text("요약 중")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .accessibilityLabel("AI 요약 진행 중")
                } else if summaryStatus == .completed {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Color.mainColor)
                        .accessibilityLabel("요약 완료")
                }

                if isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.mainColor)
                        .accessibilityLabel("즐겨찾기")
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(highlighted(link.title))
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                if let summary = summaryPreview {
                    Text(highlighted(summary))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                } else if let memo = link.personalMemo, !memo.isEmpty {
                    Text(highlighted(memo))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            HStack(spacing: 8) {
                Text(
                    link.savedDate
                        .formatted(.relative(presentation: .named))
                )
                .foregroundStyle(.tertiary)

                if !isRead {
                    Label("읽지 않음", systemImage: "circle.fill")
                        .foregroundStyle(Color.mainColor)
                }

                if isReadLater {
                    Label("나중에 읽기", systemImage: "bookmark.fill")
                        .foregroundStyle(Color.mainColor)
                }

                Spacer(minLength: 4)

                ForEach((link.categories ?? []).prefix(2)) { category in
                    Text("#\(category.name)")
                        .foregroundStyle(Color(hex: category.safeColor))
                }
            }
            .font(.caption)
            .lineLimit(1)
        }
        .padding(16)
        .background(Color.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .contentShape(Rectangle())
        .onAppear {
            let record = UserDefaults.shared.summaryRecord(for: link.id)
            summaryStatus = record?.status
            summaryText = record?.summary
        }
        .onReceive(NotificationCenter.default.publisher(for: .summaryStatusChanged)) { notification in
            guard notification.object as? UUID == link.id else { return }
            let record = UserDefaults.shared.summaryRecord(for: link.id)
            summaryStatus = record?.status
            summaryText = record?.summary
        }
        .onTapGesture(perform: onTap)
        .contextMenu {
            Button(action: onRead) {
                Label(
                    isRead ? "읽지 않음으로 표시" : "읽음으로 표시",
                    systemImage: isRead ? "circle" : "checkmark.circle"
                )
            }

            Button(action: onReadLater) {
                Label(
                    isReadLater ? "나중에 읽기 해제" : "나중에 읽기",
                    systemImage: isReadLater ? "bookmark.slash" : "bookmark"
                )
            }

            if let onReminder {
                Button(action: onReminder) {
                    Label("읽기 알림 설정", systemImage: "bell")
                }
            }

            Button(action: onFavorite) {
                Label(
                    isFavorite ? "즐겨찾기 해제" : "즐겨찾기",
                    systemImage: isFavorite ? "star.slash" : "star"
                )
            }

            if let url = URL(string: link.url) {
                ShareLink(item: url) {
                    Label(
                        LocalizedStringResource(
                            "btn_share",
                            defaultValue: "공유"
                        ),
                        systemImage: "square.and.arrow.up"
                    )
                }
            }

            if URL(string: link.url) != nil {
                Button(action: onCopy) {
                    Label(
                        LocalizedStringResource("btn_copy", defaultValue: "복사"),
                        systemImage: "link"
                    )
                }
            }

            if let onSummary {
                Button(action: onSummary) {
                    Label("AI 요약", systemImage: "sparkles")
                }
            }

            Button(action: onEdit) {
                Label(
                    LocalizedStringResource("btn_edit", defaultValue: "수정"),
                    systemImage: "pencil"
                )
            }

            Button(role: .destructive, action: onDelete) {
                Label(
                    LocalizedStringResource("btn_delete", defaultValue: "삭제"),
                    systemImage: "trash"
                )
            }
        }
    }

    private func highlighted(_ text: String) -> AttributedString {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return AttributedString(text) }

        var result = AttributedString()
        var remaining = text[...]
        while let range = remaining.range(of: query, options: .caseInsensitive) {
            result += AttributedString(String(remaining[..<range.lowerBound]))
            var match = AttributedString(String(remaining[range]))
            match.backgroundColor = .yellow.opacity(0.35)
            result += match
            remaining = remaining[range.upperBound...]
        }
        result += AttributedString(String(remaining))
        return result
    }

    private var siteLabel: String {
        if let siteName = link.siteName, !siteName.isEmpty { return siteName }
        return URL(string: link.url)?.host ?? link.url
    }

    private var summaryPreview: String? {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let summary = summaryText, !summary.isEmpty else { return nil }
        if !query.isEmpty && !summary.localizedCaseInsensitiveContains(query) { return nil }
        return summary
    }
}
