import Foundation
import WebKit
import AppsFlyerLib
import Firebase
import FirebaseMessaging

protocol NetworkGateway {
    func validate() async throws -> Bool
    func fetchAttribution() async throws -> [String: String]
    func fetchDestination(attribution: [String: String]) async throws -> String
}

final class LiveGateway: NetworkGateway {

    private let session: URLSession = {
        let cfg = URLSessionConfiguration.ephemeral
        cfg.timeoutIntervalForRequest  = 30
        cfg.timeoutIntervalForResource = 90
        cfg.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        cfg.urlCache = nil
        return URLSession(configuration: cfg)
    }()

    func validate() async throws -> Bool {
        try await withCheckedThrowingContinuation { cont in
            Database.database().reference().child("users/log/data")
                .observeSingleEvent(of: .value) { snap in
                    if let s = snap.value as? String, !s.isEmpty, URL(string: s) != nil {
                        cont.resume(returning: true)
                    } else {
                        cont.resume(returning: false)
                    }
                } withCancel: { cont.resume(throwing: $0) }
        }
    }

    func fetchAttribution() async throws -> [String: String] {
        let deviceID = AppsFlyerLib.shared().getAppsFlyerUID()
        var comps = URLComponents(string: "https://gcdsdk.appsflyer.com/install_data/v4.0/id\(RigConfig.appID)")
        comps?.queryItems = [
            .init(name: "devkey",    value: RigConfig.devKey),
            .init(name: "device_id", value: deviceID)
        ]
        guard let url = comps?.url else { throw GatewayError.badURL }

        var req = URLRequest(url: url)
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, resp) = try await session.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw GatewayError.failed
        }
        guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw GatewayError.decode
        }
        return dict.mapValues { "\($0)" }
    }

    private var ua: String = WKWebView().value(forKey: "userAgent") as? String ?? ""

    func fetchDestination(attribution: [String: String]) async throws -> String {
        guard let url = URL(string: "https://riigguide.com/config.php") else {
            throw GatewayError.badURL
        }

        var body: [String: Any] = attribution.mapValues { $0 as Any }
        body["os"]                  = "iOS"
        body["af_id"]               = AppsFlyerLib.shared().getAppsFlyerUID()
        body["bundle_id"]           = Bundle.main.bundleIdentifier ?? ""
        body["firebase_project_id"] = FirebaseApp.app()?.options.gcmSenderID
        body["store_id"]            = "id\(RigConfig.appID)"
        body["push_token"]          = UserDefaults.standard.string(forKey: "push_token") ?? Messaging.messaging().fcmToken
        body["locale"]              = Locale.preferredLanguages.first.map { String($0.prefix(2)).uppercased() } ?? "EN"

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue(ua, forHTTPHeaderField: "User-Agent")
        req.httpBody = try JSONSerialization.data(withJSONObject: body)

        // UNIQUE retry: [10, 20, 40]
        let delays: [Double] = [10.0, 20.0, 40.0]
        var last: Error?

        for (i, delay) in delays.enumerated() {
            do {
                let (data, resp) = try await session.data(for: req)
                guard let http = resp as? HTTPURLResponse else { throw GatewayError.failed }

                if (200...299).contains(http.statusCode) {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                          json["ok"] as? Bool == true,
                          let dest = json["url"] as? String else { throw GatewayError.decode }
                    return dest
                } else if http.statusCode == 429 {
                    try await Task.sleep(nanoseconds: UInt64(delay * Double(i + 1) * 1_000_000_000))
                    continue
                } else {
                    throw GatewayError.failed
                }
            } catch {
                last = error
                if i < delays.count - 1 {
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        throw last ?? GatewayError.failed
    }
}
