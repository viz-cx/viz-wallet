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

    var body: some Scene {
        WindowGroup {
            IntermediateView().environmentObject(UserAuth())
        }
    }
}

private struct IntermediateView: View {
    @EnvironmentObject private var userAuth: UserAuth
    
    var body: some View {
        NavigationView {
            if !userAuth.isLoggedIn {
                LoginView().navigationBarHidden(true)
            } else {
                MainView().navigationBarHidden(true)
            }
        }
    }
}
