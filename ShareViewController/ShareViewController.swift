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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
            let itemProvider = extensionItem.attachments?.first else {
            self.completeRequest()
            return
        }
        
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (url, error) in
                DispatchQueue.main.async {
                    if let url = url as? URL {
                        self?.showURLSaveView(url: url, extensionContext: self?.extensionContext)
                    } else {
                        self?.completeRequest()
                    }
                }
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier("public.plain-txt") {
            itemProvider.loadItem(forTypeIdentifier: "public.plain-txt", options: nil) { [weak self] (text, error) in
                DispatchQueue.main.async {
                    if let urlString = text as? String, let url = URL(string: urlString) {
                        self?.showURLSaveView(url: url, extensionContext: self?.extensionContext)
                    } else {
                        self?.completeRequest()
                    }
                }
            }
        } else {
            self.completeRequest()
        }

    }
    
    private func showURLSaveView(url: URL, extensionContext: NSExtensionContext? = nil) {
        let shareView = ShareView(url: url, extensionContext: extensionContext)
        let hostingController = UIHostingController(rootView: shareView)
        
        hostingController.modalPresentationStyle = .formSheet
        self.present(hostingController, animated: true, completion: nil)
    }
    
    private func showSavedAlert(url: URL) {
        let alert = UIAlertController(
            title: "URL 저장됨",
            message: "URL이 성공적으로 저장되었습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default) { _ in
            self.completeRequest()
        })
        
        self.present(alert, animated: true)
    }
    
    private func completeRequest() {
        self.extensionContext?
            .completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func cancelRequest(_ error: ShareError) {
        self.extensionContext?.cancelRequest(withError: error)
    }

}
