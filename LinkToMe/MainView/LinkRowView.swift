//
//  LinkRowView.swift
//  LinkToMe
//
//  Created by 심관혁 on 4/2/25.
//

import SwiftUI

struct LinkRowView: View {
    let link: LinkItem
    let onTap: () -> Void
    let onCopy: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(link.title)
                .font(.headline)
            
            Text(link.url)
                .font(.subheadline)
                .foregroundColor(.blue)
            
            if let memo = link.personalMemo, !memo.isEmpty {
                Text(memo)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .onTapGesture(perform: onTap)
        .swipeActions {
            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
            
            Button(action: onEdit) {
                Label("수정", systemImage: "pencil")
            }
        }
        .contextMenu {
            if let url = URL(string: link.url) {
                ShareLink(item: url) {
                    Label("공유", systemImage: "square.and.arrow.up")
                }
            }
            
            if let _ = URL(string: link.url) {
                Button(action: onCopy) {
                    Label("복사", systemImage: "link")
                }
            }
            
            Button(action: onEdit) {
                Label("수정", systemImage: "pencil")
            }
            
            Button(role: .destructive, action: onDelete) {
                Label("삭제", systemImage: "trash")
            }
        }
    }
}

#Preview {
    LinkRowView(link: LinkItem(url: "google.com", title: "구글"), onTap: {}, onCopy: {}, onEdit: {}, onDelete: {})
}
