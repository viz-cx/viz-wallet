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
            LoginView()
        }
    }
    
    init() {
        getAccount()
    }
}

func getAccount() {
    let client = VIZ.Client(address: URL(string: "https://node.viz.cx")!)
    let req = API.GetDynamicGlobalProperties()
    client.send(req) { res, error in
        print(res, error)
    }
}
