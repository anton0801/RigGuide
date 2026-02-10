import SwiftUI
import WebKit

struct CompareRigsView: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @State private var selectedRigs: [FishingRig] = []
    @State private var showRigPicker = false
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                Text("Compare")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 15)
                
                if selectedRigs.isEmpty {
                    EmptyStateView(
                        icon: "arrow.left.arrow.right",
                        title: "Compare Rigs",
                        message: "Select 2-3 rigs to compare"
                    )
                    
                    Button(action: {
                        showRigPicker = true
                    }) {
                        Text("Select Rigs")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(AppColors.accent)
                            .cornerRadius(25)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal, 40)
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Selected rigs
                            ForEach(selectedRigs) { rig in
                                SelectedRigCard(rig: rig) {
                                    selectedRigs.removeAll { $0.id == rig.id }
                                }
                            }
                            
                            // Add more button
                            if selectedRigs.count < 3 {
                                Button(action: {
                                    showRigPicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                        Text("Add Another Rig")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(AppColors.accent)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(AppColors.card)
                                    .cornerRadius(12)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                            
                            // Comparison table
                            if selectedRigs.count >= 2 {
                                ComparisonTable(rigs: selectedRigs)
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
        .sheet(isPresented: $showRigPicker) {
            RigPickerView(selectedRigs: $selectedRigs, maxSelection: 3)
        }
    }
}

struct SelectedRigCard: View {
    let rig: FishingRig
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(AppColors.accent.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: rig.type.icon)
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.accent)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(rig.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(rig.type.rawValue + " • " + rig.difficulty.rawValue)
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.secondaryText)
            }
            
            Spacer()
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(AppColors.secondaryText)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(15)
        .background(AppColors.card)
        .cornerRadius(12)
    }
}

struct ComparisonTable: View {
    let rigs: [FishingRig]
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Comparison")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 15)
            
            VStack(spacing: 1) {
                ComparisonRow(title: "Type", values: rigs.map { $0.type.rawValue })
                ComparisonRow(title: "Difficulty", values: rigs.map { $0.difficulty.rawValue })
                ComparisonRow(title: "Species", values: rigs.map { $0.bestFor.species.joined(separator: ", ") })
                ComparisonRow(title: "Season", values: rigs.map { $0.bestFor.season.map { $0.rawValue }.joined(separator: ", ") })
                ComparisonRow(title: "Depth", values: rigs.map { $0.bestFor.depthRange })
                ComparisonRow(title: "Rating", values: rigs.map { $0.userRating.rawValue })
            }
            .background(AppColors.card)
            .cornerRadius(12)
        }
    }
}

struct ComparisonRow: View {
    let title: String
    let values: [String]
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.accent)
                .frame(width: 100, alignment: .leading)
                .padding(12)
            
            ForEach(0..<values.count, id: \.self) { index in
                Text(values[index])
                    .font(.system(size: 13))
                    .foregroundColor(AppColors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(12)
                    .background(AppColors.background)
            }
        }
        .background(AppColors.divider)
    }
}

struct RigPickerView: View {
    @EnvironmentObject var rigViewModel: RigViewModel
    @Binding var selectedRigs: [FishingRig]
    let maxSelection: Int
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(rigViewModel.allRigs) { rig in
                            Button(action: {
                                toggleSelection(rig: rig)
                            }) {
                                HStack(spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .fill(AppColors.accent.opacity(0.2))
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: rig.type.icon)
                                            .font(.system(size: 24))
                                            .foregroundColor(AppColors.accent)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(rig.name)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text(rig.type.rawValue)
                                            .font(.system(size: 13))
                                            .foregroundColor(AppColors.secondaryText)
                                    }
                                    
                                    Spacer()
                                    
                                    if isSelected(rig: rig) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppColors.success)
                                    }
                                }
                                .padding(15)
                                .background(isSelected(rig: rig) ? AppColors.success.opacity(0.1) : AppColors.card)
                                .cornerRadius(12)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(selectedRigs.count >= maxSelection && !isSelected(rig: rig))
                            .opacity((selectedRigs.count >= maxSelection && !isSelected(rig: rig)) ? 0.5 : 1.0)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Select Rigs")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(AppColors.accent)
                }
            }
        }
    }
    
    private func isSelected(rig: FishingRig) -> Bool {
        selectedRigs.contains { $0.id == rig.id }
    }
    
    private func toggleSelection(rig: FishingRig) {
        if let index = selectedRigs.firstIndex(where: { $0.id == rig.id }) {
            selectedRigs.remove(at: index)
        } else if selectedRigs.count < maxSelection {
            selectedRigs.append(rig)
        }
    }
}

struct RigWebView: View {
    @State private var target: String? = ""
    @State private var active = false

    var body: some View {
        ZStack {
            if active, let s = target, let url = URL(string: s) {
                RigCanvas(url: url).ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { boot() }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempURL"))) { _ in swap() }
    }

    private func boot() {
        let temp  = UserDefaults.standard.string(forKey: "temp_url")
        let saved = UserDefaults.standard.string(forKey: "rg_destination_url") ?? ""
        target = temp ?? saved; active = true
        if temp != nil { UserDefaults.standard.removeObject(forKey: "temp_url") }
    }

    private func swap() {
        if let temp = UserDefaults.standard.string(forKey: "temp_url"), !temp.isEmpty {
            active = false; target = temp
            UserDefaults.standard.removeObject(forKey: "temp_url")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { active = true }
        }
    }
}

struct RigCanvas: UIViewRepresentable {
    let url: URL
    func makeCoordinator() -> RigAgent { RigAgent() }
    func makeUIView(context: Context) -> WKWebView {
        let w = buildView(agent: context.coordinator)
        context.coordinator.webView = w
        context.coordinator.visit(url, on: w)
        Task { await context.coordinator.restoreCookies(on: w) }
        return w
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {}

    private func buildView(agent: RigAgent) -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.processPool = WKProcessPool()
        let prefs = WKPreferences()
        prefs.javaScriptEnabled = true
        prefs.javaScriptCanOpenWindowsAutomatically = true
        cfg.preferences = prefs
        let ctrl = WKUserContentController()
        ctrl.addUserScript(WKUserScript(source: """
            (function(){
                const m=document.createElement('meta');m.name='viewport';
                m.content='width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no';
                document.head.appendChild(m);
                const s=document.createElement('style');
                s.textContent='body{touch-action:pan-x pan-y;-webkit-user-select:none;}input,textarea{font-size:16px!important;}';
                document.head.appendChild(s);
                document.addEventListener('gesturestart',e=>e.preventDefault());
                document.addEventListener('gesturechange',e=>e.preventDefault());
            })();
            """, injectionTime: .atDocumentEnd, forMainFrameOnly: false))
        cfg.userContentController = ctrl
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        let pp = WKWebpagePreferences(); pp.allowsContentJavaScript = true
        cfg.defaultWebpagePreferences = pp
        let w = WKWebView(frame: .zero, configuration: cfg)
        w.scrollView.minimumZoomScale = 1; w.scrollView.maximumZoomScale = 1
        w.scrollView.bounces = false; w.scrollView.bouncesZoom = false
        w.allowsBackForwardNavigationGestures = true
        w.scrollView.contentInsetAdjustmentBehavior = .never
        w.navigationDelegate = agent; w.uiDelegate = agent
        return w
    }
}

final class RigAgent: NSObject {
    weak var webView: WKWebView?
    private var hops = 0, maxHops = 70, prev: URL?, pin: URL?
    private var tabs: [WKWebView] = []
    private let jar = "rig_cookies"

    func visit(_ url: URL, on w: WKWebView) {
        print("🔧 [Rig] Visit: \(url)"); hops = 0
        var r = URLRequest(url: url); r.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData; w.load(r)
    }

    func restoreCookies(on w: WKWebView) async {
        guard let stored = UserDefaults.standard.object(forKey: jar)
                as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else { return }
        let store = w.configuration.websiteDataStore.httpCookieStore
        stored.values.flatMap { $0.values }
            .compactMap { HTTPCookie(properties: $0 as [HTTPCookiePropertyKey: Any]) }
            .forEach { store.setCookie($0) }
    }

    private func saveCookies(from w: WKWebView) {
        w.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
            guard let self else { return }
            var d: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            for c in cookies { var dom = d[c.domain] ?? [:]; if let p = c.properties { dom[c.name] = p }; d[c.domain] = dom }
            UserDefaults.standard.set(d, forKey: self.jar)
        }
    }
}

extension RigAgent: WKNavigationDelegate {
    func webView(_ w: WKWebView, decidePolicyFor a: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = a.request.url else { return decisionHandler(.allow) }
        prev = url
        let scheme = (url.scheme ?? "").lowercased(), path = url.absoluteString.lowercased()
        let ok: Set<String> = ["http","https","about","blob","data","javascript","file"]
        if ok.contains(scheme) || ["srcdoc","about:blank","about:srcdoc"].contains(where: { path.hasPrefix($0) }) || path == "about:blank" {
            decisionHandler(.allow)
        } else { UIApplication.shared.open(url, options: [:]); decisionHandler(.cancel) }
    }

    func webView(_ w: WKWebView, didReceiveServerRedirectForProvisionalNavigation _: WKNavigation!) {
        hops += 1
        if hops > maxHops { w.stopLoading(); if let p = prev { w.load(URLRequest(url: p)) }; hops = 0; return }
        prev = w.url; saveCookies(from: w)
    }

    func webView(_ w: WKWebView, didCommit _: WKNavigation!) { if let u = w.url { pin = u; print("✅ [Rig] Commit: \(u)") } }
    func webView(_ w: WKWebView, didFinish _: WKNavigation!) { if let u = w.url { pin = u }; hops = 0; saveCookies(from: w) }
    func webView(_ w: WKWebView, didFailProvisionalNavigation _: WKNavigation!, withError e: Error) {
        if (e as NSError).code == NSURLErrorHTTPTooManyRedirects, let p = prev { w.load(URLRequest(url: p)) }
    }
    func webView(_ w: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
           let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else { completionHandler(.performDefaultHandling, nil) }
    }
}

extension RigAgent: WKUIDelegate {
    func webView(_ w: WKWebView, createWebViewWith cfg: WKWebViewConfiguration, for a: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard a.targetFrame == nil else { return nil }
        let tab = WKWebView(frame: w.bounds, configuration: cfg)
        tab.navigationDelegate = self; tab.uiDelegate = self; tab.allowsBackForwardNavigationGestures = true
        w.addSubview(tab); tab.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([tab.topAnchor.constraint(equalTo: w.topAnchor), tab.bottomAnchor.constraint(equalTo: w.bottomAnchor), tab.leadingAnchor.constraint(equalTo: w.leadingAnchor), tab.trailingAnchor.constraint(equalTo: w.trailingAnchor)])
        let g = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(closeTab(_:))); g.edges = .left; tab.addGestureRecognizer(g)
        tabs.append(tab)
        if let u = a.request.url, u.absoluteString != "about:blank" { tab.load(a.request) }
        return tab
    }
    @objc private func closeTab(_ g: UIScreenEdgePanGestureRecognizer) {
        guard g.state == .ended else { return }
        if let last = tabs.last { last.removeFromSuperview(); tabs.removeLast() } else { webView?.goBack() }
    }
    func webView(_ w: WKWebView, runJavaScriptAlertPanelWithMessage _: String, initiatedByFrame _: WKFrameInfo, completionHandler: @escaping () -> Void) { completionHandler() }
}
