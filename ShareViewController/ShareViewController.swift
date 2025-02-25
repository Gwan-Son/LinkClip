//
//  ShareViewController.swift
//  ShareViewController
//
//  Created by 심관혁 on 2/18/25.
//

import UIKit
import SwiftUI
import SwiftData
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
//    private var modelContext: ModelContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let container = try! ModelContainer(
//            for: LinkItem.self,
//            configurations: ModelConfiguration(groupContainer: ModelConfiguration.GroupContainer.identifier("group.kr.gwanson.LinkToMe"))
//        )
//        
//        modelContext = ModelContext(container)
//        processSharedContent()
        
        isModalInPresentation = true
        
        if let itemProviders = (extensionContext!.inputItems.first as? NSExtensionItem)?.attachments {
            let hostingView = UIHostingController(rootView: ShareView(itemProvider: itemProviders, extenstionContext: extensionContext))
            hostingView.view.frame = view.frame
            view.addSubview(hostingView.view)
        }
        
    }
    
//    private func processSharedContent() {
//        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
//              let itemProvider = extensionItem.attachments?.first else {
//            extensionContext?.completeRequest(returningItems: nil)
//            return
//        }
//        
//        // URL 추출
//        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
//            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier) { [weak self] item, error in
//                guard let self = self, let url = item as? URL else { return }
//                
//                let newLink = LinkItem(url: url, title: url.host ?? "Untitled")
//                self.modelContext.insert(newLink)
//                 self.notifyMainApp()
//                DispatchQueue.main.async {
//                    self.extensionContext?.completeRequest(returningItems: nil)
//                }
//            }
//        }
//    }
//    
//    private func notifyMainApp() {
//        let userDefaults = UserDefaults(suiteName: "group.kr.gwanson.LinkToMe")
//        userDefaults?.set(true, forKey: "newLinkAdded")
//        userDefaults?.synchronize()
//    }

}

fileprivate struct ShareView: View {
    var itemProvider: [NSItemProvider]
    var extenstionContext: NSExtensionContext?
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Add to Link")
                .font(.title3.bold())
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    Button("Cancel", action: dismiss)
                        .tint(.red)
                }
                .padding(.bottom, 10)
            
            Button(action: {}) {
                Text("Save")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(.blue, in: .rect(cornerRadius: 10))
                    .contentShape(.rect)
            }
            
            Spacer(minLength: 0)
        }
        .padding(15)
        
    }
    
    
    
    func dismiss() {
        extenstionContext?.completeRequest(returningItems: [])
    }
}
