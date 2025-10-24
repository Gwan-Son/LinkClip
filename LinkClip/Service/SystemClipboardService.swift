//
//  SystemClipboardService.swift
//  LinkClip
//
//  Created by 심관혁 on 10/24/25.
//

import UIKit

public final class SystemClipboardService: ClipboardService {
    public init() {}

    public func copy(_ text: String) {
        UIPasteboard.general.string = text
    }
}
