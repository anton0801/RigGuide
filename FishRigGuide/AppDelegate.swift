import UIKit
import FirebaseCore
import FirebaseMessaging
import AppTrackingTransparency
import UserNotifications
import AppsFlyerLib

final class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    private let attrPipe = AttributionPipe()
    private let pushPipe = PushPipe()
    private var sdkPipe:  SDKPipe?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        attrPipe.onAttribution = { [weak self] in self?.forward(attribution: $0) }
        attrPipe.onDeeplink    = { [weak self] in self?.forward(deeplink: $0) }
        sdkPipe = SDKPipe(pipe: attrPipe)

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
        sdkPipe?.configure()

        if let push = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            pushPipe.ingest(push)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(activate), name: UIApplication.didBecomeActiveNotification, object: nil)
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    @objc private func activate() { sdkPipe?.launch() }

    private func forward(attribution data: [AnyHashable: Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            NotificationCenter.default.post(name: .init("ConversionDataReceived"), object: nil, userInfo: ["conversionData": data])
        }
    }

    private func forward(deeplink data: [AnyHashable: Any]) {
        NotificationCenter.default.post(name: .init("deeplink_values"), object: nil, userInfo: ["deeplinksData": data])
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, error in
            guard error == nil, let token else { return }
            UserDefaults.standard.set(token, forKey: "fcm_token")
            UserDefaults.standard.set(token, forKey: "push_token")
            UserDefaults(suiteName: "group.rig.depot")?.set(token, forKey: "shared_fcm")
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        pushPipe.ingest(notification.request.content.userInfo); completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        pushPipe.ingest(response.notification.request.content.userInfo); completionHandler()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        pushPipe.ingest(userInfo); completionHandler(.newData)
    }
}

final class PushPipe: NSObject {
    func ingest(_ payload: [AnyHashable: Any]) {
        guard let url = extract(from: payload) else { return }
        UserDefaults.standard.set(url, forKey: "temp_url")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            NotificationCenter.default.post(name: .init("LoadTempURL"), object: nil, userInfo: ["temp_url": url])
        }
    }

    private func extract(from p: [AnyHashable: Any]) -> String? {
        if let u = p["url"] as? String { return u }
        if let d = p["data"] as? [String: Any], let u = d["url"] as? String { return u }
        if let a = p["aps"] as? [String: Any], let d = a["data"] as? [String: Any], let u = d["url"] as? String { return u }
        if let c = p["custom"] as? [String: Any], let u = c["target_url"] as? String { return u }
        return nil
    }
}

final class SDKPipe: NSObject, AppsFlyerLibDelegate, DeepLinkDelegate {
    private var pipe: AttributionPipe
    init(pipe: AttributionPipe) { self.pipe = pipe }

    func configure() {
        let sdk = AppsFlyerLib.shared()
        sdk.appsFlyerDevKey = RigConfig.devKey; sdk.appleAppID = RigConfig.appID
        sdk.delegate = self; sdk.deepLinkDelegate = self; sdk.isDebug = false
    }

    func launch() {
        if #available(iOS 14, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                    UserDefaults.standard.set(status.rawValue, forKey: "att_status")
                }
            }
        } else { AppsFlyerLib.shared().start() }
    }

    func onConversionDataSuccess(_ data: [AnyHashable: Any]) { pipe.receiveAttribution(data) }
    func onConversionDataFail(_ error: Error) { pipe.receiveAttribution(["error": true, "error_desc": error.localizedDescription]) }
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard case .found = result.status, let dl = result.deepLink else { return }
        pipe.receiveDeeplink(dl.clickEvent)
    }
}
