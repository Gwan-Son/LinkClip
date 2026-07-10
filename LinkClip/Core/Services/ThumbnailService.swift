import Foundation

struct LinkMetadata: Sendable {
    let imageURL: URL?
    let siteName: String?
}

final class ThumbnailService {
    static let shared = ThumbnailService()

    private init() {}

    func fetchMetadata(from url: URL) async throws -> LinkMetadata {
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse,
              200 ..< 400 ~= response.statusCode,
              let html = String(data: data, encoding: .utf8) else {
            throw ThumbnailError.invalidResponse
        }

        let imagePatterns = [
            "<meta[^>]*property=[\"']og:image[\"'][^>]*content=[\"']([^\"']+)[\"']",
            "<meta[^>]*name=[\"']image[\"'][^>]*content=[\"']([^\"']+)[\"']",
            "<img[^>]*src=[\"']([^\"']+)[\"']",
        ]
        let titlePatterns = [
            "<meta[^>]*property=[\"']og:title[\"'][^>]*content=[\"']([^\"']+)[\"']",
            "<title[^>]*>([^<]+)</title>",
        ]

        let imageURL = imagePatterns.lazy
            .compactMap { self.extract(from: html, pattern: $0) }
            .compactMap { URL(string: $0, relativeTo: url)?.absoluteURL }
            .first
        let siteName = titlePatterns.lazy
            .compactMap { self.extract(from: html, pattern: $0) }
            .first ?? url.host

        return LinkMetadata(imageURL: imageURL, siteName: siteName)
    }

    private func extract(from html: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        let string = html as NSString
        let range = NSRange(location: 0, length: string.length)
        guard let match = regex.firstMatch(in: html, range: range), match.numberOfRanges > 1 else {
            return nil
        }
        return string.substring(with: match.range(at: 1))
    }
}

enum ThumbnailError: Error {
    case invalidResponse
}
