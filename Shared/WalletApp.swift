//
//  WalletApp.swift
//  Shared
//
//  Created by Vladimir Babin on 21.02.2021.
//

import os
import SwiftUI
import VIZ

private let log = Logger(subsystem: "cx.viz.viz-wallet", category: "app")

@main
struct WalletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var userAuth = UserAuthStore()

    var body: some Scene {
        WindowGroup {
            IntermediateView()
                .environment(userAuth)
                .onOpenURL(perform: handleURL)
        }
    }
    
    private func handleURL(_ url: URL) {
        log.debug("Opened URL: \(url, privacy: .public)")
        let str = url.absoluteString.lowercased()
        if str.hasPrefix("viz://"), let atSymbolIdx = str.firstIndex(of: "@") {
            let range = str.index(after: atSymbolIdx)..<str.endIndex
            let username = str[range]
            log.debug("Parsed username: \(username, privacy: .public)")
        }
    }
}

private struct IntermediateView: View {
    @Environment(UserAuthStore.self) private var userAuth
    
    var body: some View {
        if userAuth.showOnboarding {
            OnboardingView()
        } else {
            if !userAuth.isLoggedIn {
                LoginView().toolbar(.hidden, for: .navigationBar)
            } else {
                MainView().toolbar(.hidden, for: .navigationBar)
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
