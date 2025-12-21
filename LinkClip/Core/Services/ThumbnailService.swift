//
//  ThumbnailService.swift
//  LinkClip
//
//  Created by 심관혁 on 12/5/25.
//

import Foundation

class ThumbnailService {
    static let shared = ThumbnailService()

    private init() {}

    /// URL로부터 썸네일 이미지 URL을 가져옵니다.
    /// - Parameter url: 썸네일을 가져올 URL
    /// - Returns: 썸네일 이미지 URL (Open Graph 이미지 우선)
    func fetchThumbnailURL(from url: URL) async throws -> URL? {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let htmlString = String(data: data, encoding: .utf8) else {
            throw ThumbnailError.htmlDecodingFailed
        }

        // Open Graph 이미지 태그 찾기
        let ogImagePattern = "<meta[^>]*property=[\"']og:image[\"'][^>]*content=[\"']([^\"']+)[\"']"
        let metaImagePattern = "<meta[^>]*name=[\"']image[\"'][^>]*content=[\"']([^\"']+)[\"']"

        if let ogImageURL = extractURL(from: htmlString, pattern: ogImagePattern, baseURL: url) {
            return ogImageURL
        }

        if let metaImageURL = extractURL(from: htmlString, pattern: metaImagePattern, baseURL: url) {
            return metaImageURL
        }

        // Open Graph 이미지가 없는 경우 첫 번째 이미지 태그 찾기
        let imgPattern = "<img[^>]*src=[\"']([^\"']+)[\"']"
        if let firstImageURL = extractURL(from: htmlString, pattern: imgPattern, baseURL: url) {
            return firstImageURL
        }

        return nil
    }

    /// HTML 문자열에서 정규식 패턴으로 URL을 추출합니다.
    /// - Parameters:
    ///   - html: HTML 문자열
    ///   - pattern: 정규식 패턴
    ///   - baseURL: 상대 경로 변환을 위한 기본 URL
    /// - Returns: 추출된 URL
    private func extractURL(from html: String, pattern: String, baseURL: URL? = nil) -> URL? {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            let nsString = html as NSString
            let results = regex.matches(in: html, options: [], range: NSRange(location: 0, length: nsString.length))

            for result in results {
                if result.numberOfRanges > 1 {
                    let urlString = nsString.substring(with: result.range(at: 1))
                    if let url = URL(string: urlString) {
                        // 절대 URL인 경우 그대로 반환
                        if url.scheme != nil {
                            return url
                        }
                        // 상대 경로인 경우 baseURL과 결합
                        if let baseURL = baseURL {
                            return baseURL.deletingLastPathComponent().appendingPathComponent(urlString)
                        }
                        // 프로토콜 상대 URL (//로 시작하는 경우)
                        if urlString.hasPrefix("//") {
                            return URL(string: "https:" + urlString)
                        }
                    }
                }
            }
        } catch {
            print("Regex error: \(error)")
        }
        return nil
    }
}

enum ThumbnailError: Error {
    case htmlDecodingFailed
    case networkError(Error)
    case noThumbnailFound
}
