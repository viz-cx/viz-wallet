//
//  VIZHelper.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 23.02.2021.
//

import Foundation
import VIZ

struct VIZHelper {
    private let client = VIZ.Client(address: URL(string: "https://node.viz.cx")!)
    
    func getAccount(login: String) -> API.ExtendedAccount? {
        let req = API.GetAccounts(names: [login])
        let result = try? client.sendSynchronous(req)
        guard let account = result?.first else {
            print("Account \(login) not found")
            return nil
        }
        return account
    }
    
    func getDGP() -> API.DynamicGlobalProperties? {
        let req = API.GetDynamicGlobalProperties()
        let result = try? client.sendSynchronous(req)
        return result
    }
}
