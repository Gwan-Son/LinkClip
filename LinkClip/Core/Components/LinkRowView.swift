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
    let onTap: () -> Void
    let onCopy: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    var onFavorite: () -> Void = {}

    var body: some View {
        HStack(spacing: 12) {
            // 썸네일 또는 파비콘 또는 기본 아이콘
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)

                CachedAsyncImage(
                    primaryURL: link.imageURL.flatMap(URL.init),
                    fallbackURL: link.faviconURL.flatMap(URL.init)
                )
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(highlighted(link.title))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                if let memo = link.personalMemo, !memo.isEmpty {
                    Text(highlighted(memo))
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                if link.siteName != nil || !(link.categories ?? []).isEmpty {
                    HStack(spacing: 6) {
                        if let siteName = link.siteName, !siteName.isEmpty {
                            Text(siteName)
                        }

                        ForEach((link.categories ?? []).prefix(2)) { category in
                            Text("#\(category.name)")
                        }
                    }
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                }

                Text(
                    link.savedDate
                        .formatted(.relative(presentation: .named))
                )
                .font(.system(size: 12))
                .foregroundColor(.gray)
            }

            Spacer()

            if isFavorite {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .accessibilityLabel("즐겨찾기")
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture {
            if let url = URL(string: link.url) {
                UIApplication.shared.open(url)
            }
        }
        .contextMenu {
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
}
