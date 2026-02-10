import SwiftUI

@main
struct FishRigGuideApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
        }
    }
}


struct RigConfig {
    static let appID  = "6758891050"
    static let devKey = "GiT79bCeiaaETseKt8eeBR"
}
