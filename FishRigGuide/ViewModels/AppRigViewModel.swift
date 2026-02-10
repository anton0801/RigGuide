import Foundation
import Combine
import UIKit
import UserNotifications
import Network

@MainActor
final class AppRigViewModel: ObservableObject {

    @Published var showPermissionView: Bool = false
    @Published var showOfflineView: Bool    = false
    @Published var goToMain: Bool           = false
    @Published var goToWeb: Bool            = false

    // MARK: - Internal
    private let runner: PipelineRunner
    private let store:  DataStore
    private var timeoutTask: Task<Void, Never>?
    private let networkMonitor = NWPathMonitor()

    // Attribution buffers
    private var attributionBuf: [String: String] = [:]
    private var deeplinkBuf:    [String: String] = [:]
    private var mergeTimer:     Timer?
    private var pipelineTask:   Task<Void, Never>?

    init() {
        let s = DiskStore()
        self.store  = s
        self.runner = PipelineRunner(store: s, network: LiveGateway())
        monitorNetwork()
    }

    // MARK: - Start

    func start() {
        scheduleTimeout()
    }

    // MARK: - Receive attribution (from AppDelegate)

    func receiveAttribution(_ raw: [String: Any]) {
        let data = raw.mapValues { "\($0)" }
        attributionBuf = data
        store.saveAttribution(data)
        startMergeTimer()
        if !deeplinkBuf.isEmpty { runMerge() }
    }

    func receiveDeeplink(_ raw: [String: Any]) {
        let data = raw.mapValues { "\($0)" }
        deeplinkBuf = data
        store.saveDeeplink(data)
        mergeTimer?.invalidate()
        if !attributionBuf.isEmpty { runMerge() }
    }

    private func startMergeTimer() {
        mergeTimer?.invalidate()
        mergeTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in self?.runMerge() }
        }
    }

    private func runMerge() {
        mergeTimer?.invalidate()

        var merged = attributionBuf
        for (k, v) in deeplinkBuf where merged["deep_\(k)"] == nil {
            merged["deep_\(k)"] = v
        }
        attributionBuf = merged
        store.saveAttribution(merged)

        executePipeline()
    }

    // MARK: - Execute Pipeline

    private func executePipeline() {
        pipelineTask?.cancel()
        pipelineTask = Task {
            let context = await runner.run()
            guard !Task.isCancelled else { return }
            applyOutcome(context.outcome)
        }
    }

    private func applyOutcome(_ outcome: PipelineContext.Outcome) {
        timeoutTask?.cancel()

        switch outcome {
        case .goToMain:
            goToMain = true

        case .goToWeb(let url):
            UserDefaults.standard.set(url, forKey: "rg_destination_url")
            goToWeb = true

        case .showPermission(let url):
            UserDefaults.standard.set(url, forKey: "rg_destination_url")
            showPermissionView = true

        case .offline:
            showOfflineView = true

        case .pending:
            break
        }
    }

    func allowPermission() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { [weak self] granted, _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                self.store.savePermission(granted: granted, blocked: !granted)
                if granted { UIApplication.shared.registerForRemoteNotifications() }
                self.showPermissionView = false
                self.goToWeb = true
            }
        }
    }

    func deferPermission() {
        store.savePermission(granted: false, blocked: false)
        showPermissionView = false
    }

    // MARK: - Timeout

    private func scheduleTimeout() {
        timeoutTask = Task {
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            guard !Task.isCancelled else { return }
            goToMain = true
        }
    }

    // MARK: - Network

    private func monitorNetwork() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                let connected = path.status == .satisfied
                if !connected && !self.goToWeb && !self.goToMain {
                    self.showOfflineView = true
                } else if connected {
                    self.showOfflineView = false
                }
            }
        }
        networkMonitor.start(queue: .global(qos: .background))
    }
}
