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
        
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem else {
            return
        }
        
        let hostingView = UIHostingController(
            rootView:
                ShareView(
                    extensionItem: extensionItem,
                    completeRequest: completeRequest,
                    cancelRequest: cancelRequest
                )
        )
        
        self.addChild(hostingView)
        self.view.addSubview(hostingView.view)
        hostingView.view.translatesAutoresizingMaskIntoConstraints = false
        
        hostingView.view.topAnchor
            .constraint(equalTo: view.topAnchor).isActive = true
        hostingView.view.leadingAnchor
            .constraint(equalTo: view.leadingAnchor).isActive = true
        hostingView.view.trailingAnchor
            .constraint(equalTo: view.trailingAnchor).isActive = true
        hostingView.view.bottomAnchor
            .constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func completeRequest() {
        self.extensionContext?
            .completeRequest(returningItems: [], completionHandler: nil)
    }
    
    private func cancelRequest(_ error: ShareError) {
        self.extensionContext?.cancelRequest(withError: error)
    }

}
