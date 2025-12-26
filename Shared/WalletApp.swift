//
//  WalletApp.swift
//  Shared
//
//  Created by Vladimir Babin on 21.02.2021.
//

import SwiftUI
import VIZ

@main
struct WalletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            IntermediateView()
                .environmentObject(UserAuth())
                .onOpenURL(perform: handleURL)
        }
    }
    
    private func handleURL(_ url: URL) {
        print("URL: \(url)")
        let str = url.absoluteString.lowercased()
        if str.hasPrefix("viz://"), let atSymbolIdx = str.firstIndex(of: "@") {
            let range = str.index(after: atSymbolIdx)..<str.endIndex
            let username = str[range]
            print(username)
        }
    }
}

private struct IntermediateView: View {
    @EnvironmentObject private var userAuth: UserAuth
    
    var body: some View {
        if userAuth.showOnboarding {
            OnboardingView()
        } else {
            if !userAuth.isLoggedIn {
                LoginView().navigationBarHidden(true)
            } else {
                MainView().navigationBarHidden(true)
            }
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerDefaultsFromSettingsBundle()
        if ProcessInfo.processInfo.arguments.contains("-ui-testing") {
            UIView.setAnimationsEnabled(false)
        }
        return true
    }
}

private func registerDefaultsFromSettingsBundle() {
    let settingsUrl = Bundle.main.url(forResource: "Settings", withExtension: "bundle")!.appendingPathComponent("Root.plist")
    let settingsPlist = NSDictionary(contentsOf:settingsUrl)!
    let preferences = settingsPlist["PreferenceSpecifiers"] as! [NSDictionary]

    var defaultsToRegister = Dictionary<String, Any>()

    for preference in preferences {
        guard let key = preference["Key"] as? String else {
            NSLog("Key not found")
            continue
        }
        defaultsToRegister[key] = preference["DefaultValue"]
    }
    UserDefaults.standard.register(defaults: defaultsToRegister)
}
