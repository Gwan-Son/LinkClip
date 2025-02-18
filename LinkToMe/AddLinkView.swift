//
//  AddLinkView.swift
//  LinkToMe
//
//  Created by 심관혁 on 2/18/25.
//

import SwiftUI

struct AddLinkView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var urlString = ""
    @State private var title = ""
    @State private var selectedTags: Set<Tag> = []
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("URL 입력", text: $urlString)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                    TextField("제목",text: $title)
                }
                
                TagSelectionView(selectedTags: $selectedTags)
            }
            .navigationTitle("새 링크 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("저장") { saveLink() }
                        .disabled(urlString.isEmpty)
                }
            }
        }
    }
    
    private func saveLink() {
        guard let url = URL(string: urlString) else { return }
        let newLink = LinkItem(url: url, title: title, tags: Array(selectedTags))
        context.insert(newLink)
        dismiss()
    }
}

#Preview {
    AddLinkView()
}
