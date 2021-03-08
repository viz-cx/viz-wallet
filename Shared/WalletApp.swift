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
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            IntermediateView().environmentObject(UserAuth())
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

//final class AppDelegate: NSObject, UIApplicationDelegate {}

private struct IntermediateView: View {
    @EnvironmentObject private var userAuth: UserAuth
    
    var body: some View {
        if !userAuth.isLoggedIn {
            LoginView().navigationBarHidden(true)
        } else {
            MainView().navigationBarHidden(true)
        }
    }
}
