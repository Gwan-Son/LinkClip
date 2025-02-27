////
////  ShareExtensionViewController.swift
////  LinkToMe
////
////  Created by 심관혁 on 2/18/25.
////
//
//import UIKit
//import SwiftUI
//import SwiftData
//
//class ShareExtensionViewController: UIViewController {
//    override func viewDidLoad() {
//        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
//              let itemProvider = extensionItem.attachments?.first else {
//            extensionContext?.completeRequest(returningItems: nil)
//            return
//        }
//        
//        if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
//            itemProvider.loadItem(forTypeIdentifier: "public.url") { [weak self] url, error in
//                guard let self = self, let url = url as? URL else { return }
//                
//                // SwiftData 컨테이너 설정
//                let container = try! ModelContainer(for: LinkItem.self)
//                
//                // 새로운 링크 생성
//                let newLink = LinkItem(url: url, title: url.host ?? "Untitled")
//                container.mainContext.insert(newLink)
//                
//                self.extensionContext?.completeRequest(returningItems: nil)
//            }
//        }
//    }
//}
