//
//  SystemURLOpener.swift
//  LinkClip
//
//  Created by 심관혁 on 10/24/25.
//

import UIKit

public final class SystemURLOpener: URLOpener {
    public init() {}

    public func open(_ url: URL) {
        UIApplication.shared.open(url)
    }
}
