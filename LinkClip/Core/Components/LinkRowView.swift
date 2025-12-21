//
//  LinkRowView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

struct LinkRow: View {
    let link: LinkItem
    let onTap: () -> Void
    let onCopy: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

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
                Text(link.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)

                if let memo = link.personalMemo, !memo.isEmpty {
                    Text(memo)
                        .font(.system(size: 14))
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

            Image(systemName: "chevron.right")
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture { // TODO: - onTap으로 수정
            if let url = URL(string: link.url) {
                UIApplication.shared.open(url)
            }
        }
        .contextMenu {
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
}
