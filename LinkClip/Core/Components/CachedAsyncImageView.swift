//
//  CachedAsyncImageView.swift
//  LinkClip
//
//  Created by 심관혁 on 12/16/25.
//

import SwiftUI

struct CachedAsyncImage: View {
    let primaryURL: URL?
    let fallbackURL: URL?

    @State private var image: Image?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let image = image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if isLoading {
                ProgressView()
                    .frame(width: 20, height: 20)
            } else {
                Image(systemName: "link")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
        }
        .task {
            await loadImage()
        }
        .onDisappear {
            // 뷰가 사라질 때 이미지 메모리 정리
            image = nil
        }
    }

    private func loadImage() async {
        guard !isLoading, image == nil else { return }
        isLoading = true
        defer { isLoading = false }

        // 우선순위: 썸네일 > 파비콘
        let urls = [primaryURL, fallbackURL].compactMap { $0 }

        for url in urls {
            if let loadedImage = await loadImageFromURL(url) {
                image = loadedImage
                break
            }
        }
    }

    private func loadImageFromURL(_ url: URL) async -> Image? {
        // URLCache를 활용한 기본 캐싱 (메모리 + 디스크 캐시)
        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataElseLoad,
            timeoutInterval: 10
        )

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            // 메모리 사용량 체크 (10MB 이상이면 압축)
            if data.count > 10_000_000, let uiImage = UIImage(data: data) {
                // 큰 이미지는 압축하여 메모리 절약
                let compressedImage = compressImage(uiImage, maxSize: 200)
                return Image(uiImage: compressedImage)
            } else if let uiImage = UIImage(data: data) {
                return Image(uiImage: uiImage)
            }
        } catch {
            print("이미지 로드 실패: \(url) - \(error)")
        }
        return nil
    }

    private func compressImage(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        let maxDimension = max(size.width, size.height)

        if maxDimension <= maxSize {
            return image
        }

        let scale = maxSize / maxDimension
        let newSize = CGSize(
            width: size.width * scale,
            height: size.height * scale
        )

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let compressedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return compressedImage ?? image
    }
}
