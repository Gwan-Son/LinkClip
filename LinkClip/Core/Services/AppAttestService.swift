import CryptoKit
import DeviceCheck
import Foundation

actor AppAttestManager {
    static let shared = AppAttestManager()

    private struct Challenge: Decodable { let challenge: String }
    private struct AttestationBody: Encodable {
        let client_id: String
        let key_id: String
        let challenge: String
        let attestation: String
    }
    private struct SessionBody: Encodable {
        let client_id: String
        let key_id: String
        let challenge: String
        let assertion: String
    }
    private struct Session: Decodable {
        let token: String
        let expires_in: TimeInterval
    }

    func prepareSession() async {
        guard DCAppAttestService.shared.isSupported else { return }
        do {
            let expiration = UserDefaults.shared.double(forKey: UserDefaults.Keys.summaryAuthExpiration)
            guard expiration < Date().addingTimeInterval(3600).timeIntervalSince1970 else { return }
            if let keyID = UserDefaults.shared.string(forKey: UserDefaults.Keys.appAttestKeyID) {
                do {
                    try await renewSession(keyID: keyID)
                    return
                } catch {
                    UserDefaults.shared.removeObject(forKey: UserDefaults.Keys.appAttestKeyID)
                }
            }
            let keyID = try await DCAppAttestService.shared.generateKey()
            UserDefaults.shared.set(keyID, forKey: UserDefaults.Keys.appAttestKeyID)
            try await attest(keyID: keyID)
        } catch {
            // 인증 서버 장애가 기존 링크 저장을 막아서는 안 된다.
            print("App Attest 준비 실패: \(error.localizedDescription)")
        }
    }

    private func attest(keyID: String) async throws {
        let challenge = try await fetchChallenge()
        let clientID = UserDefaults.shared.summaryInstallationID
        let challengeData = Data(base64Encoded: challenge)!
        let attestation = try await DCAppAttestService.shared.attestKey(
            keyID, clientDataHash: Data(SHA256.hash(data: challengeData))
        )
        let session: Session = try await post(
            "auth/attest",
            body: AttestationBody(
                client_id: clientID,
                key_id: keyID,
                challenge: challenge,
                attestation: attestation.base64EncodedString()
            )
        )
        save(session)
    }

    private func renewSession(keyID: String) async throws {
        let challenge = try await fetchChallenge()
        let clientID = UserDefaults.shared.summaryInstallationID
        let clientData = Data("session:\(clientID):\(challenge)".utf8)
        let assertion = try await DCAppAttestService.shared.generateAssertion(
            keyID, clientDataHash: Data(SHA256.hash(data: clientData))
        )
        let session: Session = try await post(
            "auth/session",
            body: SessionBody(
                client_id: clientID,
                key_id: keyID,
                challenge: challenge,
                assertion: assertion.base64EncodedString()
            )
        )
        save(session)
    }

    private func save(_ session: Session) {
        UserDefaults.shared.set(session.token, forKey: UserDefaults.Keys.summaryAuthToken)
        UserDefaults.shared.set(
            Date().addingTimeInterval(session.expires_in).timeIntervalSince1970,
            forKey: UserDefaults.Keys.summaryAuthExpiration
        )
    }

    private func fetchChallenge() async throws -> String {
        var request = URLRequest(url: try SummaryAPI.endpoint("auth/challenge"))
        request.httpMethod = "POST"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.badServerResponse) }
        return try JSONDecoder().decode(Challenge.self, from: data).challenge
    }

    private func post<Body: Encodable, Response: Decodable>(
        _ path: String, body: Body
    ) async throws -> Response {
        var request = URLRequest(url: try SummaryAPI.endpoint(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw URLError(.userAuthenticationRequired) }
        return try JSONDecoder().decode(Response.self, from: data)
    }
}
