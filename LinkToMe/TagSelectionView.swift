////
////  TagSelectionView.swift
////  LinkToMe
////
////  Created by 심관혁 on 2/18/25.
////
//
//import SwiftUI
//import SwiftData
//
//struct TagSelectionView: View {
//    @Query(sort: \Tag.name) var allTags: [Tag]
//    @Binding var selectedTags: Set<Tag>
//    
//    var body: some View {
//        Section("태그") {
//            ForEach(allTags) { tag in
//                HStack {
//                    Text(tag.name)
//                    Spacer()
//                    if selectedTags.contains(tag) {
//                        Image(systemName: "checkmark")
//                    }
//                }
//                .contentShape(Rectangle())
//                .onTapGesture {
//                    toggleSelection(for: tag)
//                }
//            }
//        }
//    }
//    
//    private func toggleSelection(for tag: Tag) {
//        if selectedTags.contains(tag) {
//            selectedTags.remove(tag)
//        } else {
//            selectedTags.insert(tag)
//        }
//    }
//}
//
////#Preview {
////    TagSelectionView()
////}
