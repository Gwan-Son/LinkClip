//
//  ShareView.swift
//  LinkToMe
//
//  Created by 심관혁 on 3/11/25.
//

import SwiftUI
import UniformTypeIdentifiers

enum ViewMode {
    case view
    case edit
}
// TODO: - SwiftData 적용
struct ShareView: View {
    private static let groupId = "group.kr.gwanson.LinkToMe"
    @AppStorage("title", store: UserDefaults(suiteName: Self.groupId)) private var savedTitle: String = ""
    @AppStorage("url", store: UserDefaults(suiteName: Self.groupId)) private var savedUrl: String = ""
    @AppStorage("extraNote", store: UserDefaults(suiteName: Self.groupId)) private var savedNote: String = ""
    
    private let extensionItem: NSExtensionItem
    private let completeRequest: (() -> Void)?
    private let cancelRequest: ((ShareError) -> Void)?
    
    private let urlType = UTType.url.identifier
    
    @State private var title: String?
    @State private var url: URL?
    @State private var entry: String = ""
    @State private var viewMode: ViewMode
    
    var body: some View {
        VStack(spacing: 24) {
            if viewMode == .view && savedUrl.isEmpty && savedNote.isEmpty {
                VStack(spacing: 16) {
                    Text("No Previous Saved Info Available!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    Text("Head to Safari and try to share a URL or some text!")
                        .multilineTextAlignment(.center)
                }
                .frame(maxHeight: .infinity, alignment: .center)

                
            } else {
                if viewMode == .view {
                    Text("Previous Saved Info")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                if let title {
                    VStack(spacing: 16) {
                        Text("Title")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(title)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                if let url {
                    VStack(spacing: 16) {
                        Text("URL")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(LocalizedStringKey(url.absoluteString))
                            .multilineTextAlignment(.leading)
                    }
                }
                
                if title != nil || url != nil {
                    Divider()
                        .background(.black)
                }
                
                VStack(spacing: 16) {
                    Text("Some Extra Notes")
                    TextField("", text: $entry, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(5, reservesSpace: true)
                        .shadow(radius: 1)
                        .lineSpacing(4)
                        .disabled(viewMode == .view)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 64)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .overlay(alignment: .topTrailing, content: {
            if let completeRequest {
                Button(action: {
                    savedTitle = title ?? ""
                    savedUrl = url?.absoluteString ?? ""
                    savedNote = entry
                    completeRequest()
                }, label: {
                    Text("Save")
                })
            }
        })
        .overlay(alignment: .topLeading, content: {
            if let completeRequest {
                Button(action: {
                    completeRequest()
                }, label: {
                    Text("Cancel")
                        .foregroundStyle(.red)
                })
            }
        })
        .padding()
        .onAppear {
            if viewMode == .view {
                self.title = savedTitle
                self.url = URL(string: savedUrl)
                self.entry = savedNote
                return
            }
            do {
                try processItems(extensionItem)
            } catch (let error) {
                print(error)
                if error is ShareError {
                    cancelRequest?(error as! ShareError)
                } else {
                    cancelRequest?(.unknown)
                }
            }
        }
        .onChange(of: [savedTitle, savedUrl, savedNote], {
            self.title = savedTitle
            self.url = URL(string: savedUrl)
            self.entry = savedNote

        })
    }
    
    nonisolated private func processItems(_ extensionItem: NSExtensionItem) throws {
        var title: String?
        var url: URL?
        Task {
            title = extensionItem.attributedContentText?.string ?? "No title"
            
            guard let itemProviders = extensionItem.attachments else {
                print("item not found!")
                throw ShareError.itemNotFound
            }
            
            for itemProvider in itemProviders {
                if itemProvider.hasItemConformingToTypeIdentifier(urlType) {
                    let data = try await itemProvider.loadItem(forTypeIdentifier: urlType)
                    print("url", data)
                    
                    guard let urlData = data as? NSURL as? URL else {
                        print("error getting url data")
                        throw ShareError.loadItemError
                    }
                    
                    url = urlData
                    
                    continue
                }
            }
            
            if url == nil {
                print("ShareError.itemNotFound")
                throw ShareError.itemNotFound
            }
            
            DispatchQueue.main.async { [url, title] in
                self.url = url
                self.title = title
            }
        }
    }
}

extension ShareView {
    init(extensionItem: NSExtensionItem, completeRequest: @escaping () -> Void, cancelRequest: @escaping (ShareError) -> Void) {
        self.extensionItem = extensionItem
        self.completeRequest = completeRequest
        self.cancelRequest = cancelRequest
        self.viewMode = .edit
    }
    
    init() {
        self.extensionItem = NSExtensionItem()
        self.completeRequest = nil
        self.cancelRequest = nil
        self.viewMode = .view
    }
}

#Preview {
    ShareView()
}
