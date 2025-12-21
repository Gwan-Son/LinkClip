////
////  LinkRowView.swift
////  LinkClip
////
////  Created by 심관혁 on 4/2/25.
////
//
//import SwiftUI
//
//struct LinkRowView: View {
//    let link: LinkItem
//    let onTap: () -> Void
//    let onCopy: () -> Void
//    let onEdit: () -> Void
//    let onDelete: () -> Void
//
//    var body: some View {
//        HStack(alignment: .top, spacing: 12) {
//            // 썸네일 이미지
//            if let imageURL = link.imageURL, let url = URL(string: imageURL) {
//                AsyncImage(url: url) { phase in
//                    switch phase {
//                    case .empty:
//                        ProgressView()
//                            .frame(width: 60, height: 60)
//                    case .success(let image):
//                        image
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 60, height: 60)
//                            .cornerRadius(8)
//                            .clipped()
//                    case .failure:
//                        Image(systemName: "photo")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
//                            .frame(width: 60, height: 60)
//                            .foregroundColor(.gray)
//                            .background(Color.gray.opacity(0.1))
//                            .cornerRadius(8)
//                    @unknown default:
//                        EmptyView()
//                    }
//                }
//            } else {
//                // 썸네일이 없는 경우 기본 아이콘 표시
//                Image(systemName: "link")
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 60, height: 60)
//                    .foregroundColor(.gray)
//                    .background(Color.gray.opacity(0.1))
//                    .cornerRadius(8)
//            }
//
//            // 텍스트 정보
//            VStack(alignment: .leading, spacing: 8) {
//                Text(link.title)
//                    .font(.headline)
//                    .lineLimit(2)
//
//                Text(link.url)
//                    .font(.subheadline)
//                    .foregroundColor(.blue)
//                    .lineLimit(1)
//
//                if let memo = link.personalMemo, !memo.isEmpty {
//                    Text(memo)
//                        .font(.caption)
//                        .foregroundColor(.secondary)
//                        .lineLimit(2)
//                        .padding(.top, 4)
//                }
//
//                // 카테고리 표시 (여러 개 가능)
//                if let categories = link.categories, !categories.isEmpty {
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack(spacing: 6) {
//                            ForEach(categories.prefix(3)) { category in  // 최대 3개까지 표시
//                                HStack(spacing: 2) {
//                                    Image(systemName: category.icon)
//                                        .font(.caption)
//                                    Text(category.name)
//                                        .font(.caption)
//                                        .foregroundColor(.secondary)
//                                }
//                                .padding(.horizontal, 6)
//                                .padding(.vertical, 2)
//                                .background(
//                                    Capsule()
//                                        .fill(Color(hex: category.safeColor).opacity(0.1))
//                                )
//                            }
//                            if categories.count > 3 {
//                                Text("+\(categories.count - 3)")
//                                    .font(.caption)
//                                    .foregroundColor(.secondary)
//                                    .padding(.horizontal, 6)
//                                    .padding(.vertical, 2)
//                                    .background(
//                                        Capsule()
//                                            .fill(Color.gray.opacity(0.1))
//                                    )
//                            }
//                        }
//                    }
//                }
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .padding(.vertical, 8)
//        .onTapGesture(perform: onTap)
//        .swipeActions {
//            Button(role: .destructive, action: onDelete) {
//                Label(LocalizedStringResource("btn_delete", defaultValue: "삭제"), systemImage: "trash")
//            }
//            .tint(.red)
//
//            Button(action: onEdit) {
//                Label(LocalizedStringResource("btn_edit", defaultValue: "수정"), systemImage: "pencil")
//            }
//            .tint(.gray)
//        }
//        .contextMenu {
//            if let url = URL(string: link.url) {
//                ShareLink(item: url) {
//                    Label(
//                        LocalizedStringResource("btn_share", defaultValue: "공유"),
//                        systemImage: "square.and.arrow.up")
//                }
//            }
//
//            if URL(string: link.url) != nil {
//                Button(action: onCopy) {
//                    Label(LocalizedStringResource("btn_copy", defaultValue: "복사"), systemImage: "link")
//                }
//            }
//
//            Button(action: onEdit) {
//                Label(LocalizedStringResource("btn_edit", defaultValue: "수정"), systemImage: "pencil")
//            }
//
//            Button(role: .destructive, action: onDelete) {
//                Label(LocalizedStringResource("btn_delete", defaultValue: "삭제"), systemImage: "trash")
//            }
//        }
//    }
//}
//
//#Preview {
//    LinkRowView(
//        link: LinkItem(url: "google.com", title: "구글"), onTap: {}, onCopy: {}, onEdit: {}, onDelete: {})
//}
