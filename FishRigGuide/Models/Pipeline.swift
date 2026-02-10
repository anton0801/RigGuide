import Foundation
import Combine

final class PipelineContext {

    // Input data
    var attribution: [String: String] = [:]
    var deeplink: [String: String] = [:]

    // Resolved data
    var resolvedURL: String?
    var resolvedMode: String?

    // Flags
    var isFirstRun: Bool = true
    var isLocked: Bool = false

    // Permission
    var permGranted: Bool = false
    var permBlocked: Bool = false
    var permDate: Date?

    // Result
    var outcome: Outcome = .pending

    enum Outcome {
        case pending
        case goToWeb(String)
        case goToMain
        case showPermission(String)
        case offline
    }

    // Computed helpers
    var hasAttribution: Bool { !attribution.isEmpty }
    var isOrganic: Bool { attribution["af_status"] == "Organic" }

    var canAskPermission: Bool {
        guard !permGranted && !permBlocked else { return false }
        if let date = permDate {
            return Date().timeIntervalSince(date) / 86400 >= 3
        }
        return true
    }
}

protocol PipelineStep: AnyObject {
    var next: PipelineStep? { get set }
    func process(context: PipelineContext) async
}

extension PipelineStep {
    func pass(context: PipelineContext) async {
        await next?.process(context: context)
    }
}

final class LoadStep: PipelineStep {
    var next: PipelineStep?
    private let store: DataStore

    init(store: DataStore) { self.store = store }

    func process(context: PipelineContext) async {
        let data = store.load()
        context.attribution   = data.attribution
        context.deeplink      = data.deeplink
        context.resolvedURL   = data.url
        context.resolvedMode  = data.mode
        context.isFirstRun    = data.isFirstRun
        context.permGranted   = data.permGranted
        context.permBlocked   = data.permBlocked
        context.permDate      = data.permDate
        await pass(context: context)
    }
}

final class ValidateStep: PipelineStep {
    var next: PipelineStep?
    private let network: NetworkGateway

    init(network: NetworkGateway) { self.network = network }

    func process(context: PipelineContext) async {
        guard context.hasAttribution else {
            await pass(context: context)
            return
        }

        do {
            let ok = try await network.validate()
            if !ok {
                context.outcome = .goToMain
                return
            }
        } catch {
            context.outcome = .goToMain
            return
        }

        await pass(context: context)
    }
}

final class TempURLStep: PipelineStep {
    var next: PipelineStep?

    func process(context: PipelineContext) async {
        if let temp = UserDefaults.standard.string(forKey: "temp_url"), !temp.isEmpty {
            context.resolvedURL = temp
            context.outcome = context.canAskPermission ? .showPermission(temp) : .goToWeb(temp)
            return
        }
        await pass(context: context)
    }
}

final class SavedURLStep: PipelineStep {
    var next: PipelineStep?

    func process(context: PipelineContext) async {
        guard !context.hasAttribution else {
            await pass(context: context)
            return
        }

        if let saved = context.resolvedURL {
            context.outcome = context.canAskPermission ? .showPermission(saved) : .goToWeb(saved)
        } else {
            context.outcome = .goToMain
        }
    }
}

final class OrganicStep: PipelineStep {
    var next: PipelineStep?
    private let network: NetworkGateway

    init(network: NetworkGateway) { self.network = network }

    func process(context: PipelineContext) async {
        print("⛽ [Step 5] Organic")
        guard context.isFirstRun && context.isOrganic else {
            await pass(context: context)
            return
        }

        try? await Task.sleep(nanoseconds: 5_000_000_000)

        do {
            var fetched = try await network.fetchAttribution()
            for (k, v) in context.deeplink where fetched[k] == nil { fetched[k] = v }
            context.attribution = fetched
        } catch {
            context.outcome = .goToMain
            return
        }

        await pass(context: context)
    }
}

final class FetchStep: PipelineStep {
    var next: PipelineStep?
    private let network: NetworkGateway
    private let store: DataStore

    init(network: NetworkGateway, store: DataStore) {
        self.network = network
        self.store = store
    }

    func process(context: PipelineContext) async {
        do {
            let url = try await network.fetchDestination(attribution: context.attribution)
            context.resolvedURL  = url
            context.resolvedMode = "Active"
            context.isFirstRun   = false

            store.saveURL(url)
            store.saveMode("Active")
            store.markInstalled()

        } catch {
            // Fallback to saved
            guard context.resolvedURL != nil else {
                context.outcome = .goToMain
                return
            }
        }

        await pass(context: context)
    }
}

final class ResolveStep: PipelineStep {
    var next: PipelineStep?

    func process(context: PipelineContext) async {
        guard let url = context.resolvedURL else {
            context.outcome = .goToMain
            return
        }

        context.outcome = context.canAskPermission ? .showPermission(url) : .goToWeb(url)
    }
}
