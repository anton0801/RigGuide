import Foundation
import FirebaseDatabase
import AppsFlyerLib
import FirebaseCore
import FirebaseMessaging
import WebKit

protocol DataStore {
    func load() -> StoredData
    func saveAttribution(_ data: [String: String])
    func saveDeeplink(_ data: [String: String])
    func saveURL(_ url: String)
    func saveMode(_ mode: String)
    func markInstalled()
    func savePermission(granted: Bool, blocked: Bool)
}

struct StoredData {
    var attribution: [String: String]
    var deeplink: [String: String]
    var url: String?
    var mode: String?
    var isFirstRun: Bool
    var permGranted: Bool
    var permBlocked: Bool
    var permDate: Date?
}

final class DiskStore: DataStore {

    private let vault  = UserDefaults(suiteName: "group.rig.depot")!
    private let backup = UserDefaults.standard
    private var cache: [String: Any] = [:]

    // UNIQUE: rg_ prefix
    private enum K {
        static let attribution = "rg_attribution_info"
        static let deeplink    = "rg_deeplink_info"
        static let url         = "rg_destination_url"
        static let mode        = "rg_mode_setting"
        static let installed   = "rg_installed_flag"
        static let permGranted = "rg_perm_granted"
        static let permBlocked = "rg_perm_blocked"
        static let permDate    = "rg_perm_date"
    }

    init() {
        if let v = vault.string(forKey: K.url)         { cache[K.url] = v }
        if let v = vault.string(forKey: K.attribution) { cache[K.attribution] = v }
    }

    func load() -> StoredData {
        var attr: [String: String] = [:]
        if let j = cache[K.attribution] as? String ?? vault.string(forKey: K.attribution),
           let d = parseJSON(j) { attr = d }

        var dl: [String: String] = [:]
        if let enc = vault.string(forKey: K.deeplink),
           let j = decode(enc), let d = parseJSON(j) { dl = d }

        let url  = cache[K.url] as? String ?? vault.string(forKey: K.url) ?? backup.string(forKey: K.url)
        let ts   = vault.double(forKey: K.permDate)
        let date = ts > 0 ? Date(timeIntervalSince1970: ts / 1000) : nil

        return StoredData(
            attribution: attr, deeplink: dl,
            url: url, mode: vault.string(forKey: K.mode),
            isFirstRun:  !vault.bool(forKey: K.installed),
            permGranted: vault.bool(forKey: K.permGranted),
            permBlocked: vault.bool(forKey: K.permBlocked),
            permDate: date
        )
    }

    func saveAttribution(_ data: [String: String]) {
        if let j = toJSON(data) { vault.set(j, forKey: K.attribution); cache[K.attribution] = j }
    }

    func saveDeeplink(_ data: [String: String]) {
        if let j = toJSON(data) { vault.set(encode(j), forKey: K.deeplink) }
    }

    func saveURL(_ url: String) {
        vault.set(url, forKey: K.url); backup.set(url, forKey: K.url); cache[K.url] = url
    }

    func saveMode(_ mode: String)   { vault.set(mode, forKey: K.mode) }
    func markInstalled()             { vault.set(true,  forKey: K.installed) }

    func savePermission(granted: Bool, blocked: Bool) {
        vault.set(granted, forKey: K.permGranted)
        vault.set(blocked, forKey: K.permBlocked)
        vault.set(Date().timeIntervalSince1970 * 1000, forKey: K.permDate)
    }

    // UNIQUE encoding: ( and )
    private func encode(_ s: String) -> String {
        Data(s.utf8).base64EncodedString()
            .replacingOccurrences(of: "=", with: "(")
            .replacingOccurrences(of: "+", with: ")")
    }

    private func decode(_ s: String) -> String? {
        let b64 = s.replacingOccurrences(of: "(", with: "=")
                   .replacingOccurrences(of: ")", with: "+")
        guard let d = Data(base64Encoded: b64) else { return nil }
        return String(data: d, encoding: .utf8)
    }

    private func toJSON(_ d: [String: String]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: d.mapValues { $0 as Any }),
              let s = String(data: data, encoding: .utf8) else { return nil }
        return s
    }

    private func parseJSON(_ s: String) -> [String: String]? {
        guard let data = s.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return dict.mapValues { "\($0)" }
    }
}


enum GatewayError: Error { case badURL, failed, decode }

@MainActor
final class PipelineRunner {

    private let store:   DataStore
    private let network: NetworkGateway

    init(store: DataStore = DiskStore(), network: NetworkGateway = LiveGateway()) {
        self.store   = store
        self.network = network
    }

    func run() async -> PipelineContext {
        let ctx = PipelineContext()

        // Build chain
        let load     = LoadStep(store: store)
        let validate = ValidateStep(network: network)
        let temp     = TempURLStep()
        let saved    = SavedURLStep()
        let organic  = OrganicStep(network: network)
        let fetch    = FetchStep(network: network, store: store)
        let resolve  = ResolveStep()

        // Wire chain: 1 → 2 → 3 → 4 → 5 → 6 → 7
        load.next     = validate
        validate.next = temp
        temp.next     = saved
        saved.next    = organic
        organic.next  = fetch
        fetch.next    = resolve

        // Run from first step
        await load.process(context: ctx)

        return ctx
    }
}
