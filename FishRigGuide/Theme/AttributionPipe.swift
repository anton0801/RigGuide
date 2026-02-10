import Foundation

class AttributionPipe: NSObject {
    var onAttribution: (([AnyHashable: Any]) -> Void)?
    var onDeeplink:    (([AnyHashable: Any]) -> Void)?
    private var attrBuf: [AnyHashable: Any] = [:]
    private var dlBuf:   [AnyHashable: Any] = [:]
    private var timer:   Timer?

    func receiveAttribution(_ data: [AnyHashable: Any]) {
        attrBuf = data; startTimer()
        if !dlBuf.isEmpty { merge() }
    }

    func receiveDeeplink(_ data: [AnyHashable: Any]) {
        guard !UserDefaults.standard.bool(forKey: "rg_installed_flag") else { return }
        dlBuf = data; onDeeplink?(data); timer?.invalidate()
        if !attrBuf.isEmpty { merge() }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in self?.merge() }
    }

    private func merge() {
        var result = attrBuf
        dlBuf.forEach { k, v in let key = "deep_\(k)"; if result[key] == nil { result[key] = v } }
        onAttribution?(result)
    }
}
