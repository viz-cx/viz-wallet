//
//  UserAuth.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 22.02.2021.
//

import Combine
import Foundation
import VIZ

class UserAuth: ObservableObject {
    
    let objectWillChange = PassthroughSubject<UserAuth,Never>()
    
    func login(login: String, regularKey: String) {
        guard login.count > 1 else {
            print("Login too small")
            return
        }
        let client = VIZ.Client(address: URL(string: "https://node.viz.cx")!)
        let req = API.GetAccounts(names: [login])
        let result = try? client.sendSynchronous(req)
        guard let account = result?.first else {
            print("Account not found")
            return
        }
        var isRegularValid = false
        for accountAuth in account.regularAuthority.keyAuths {
            if accountAuth.weight >= account.regularAuthority.weightThreshold {
                guard let publicKey = PrivateKey(regularKey)?.createPublic() else {
                    continue
                }
                isRegularValid = publicKey.address == accountAuth.value.address
                if isRegularValid {
                    break
                }
            }
        }
        if isRegularValid {
            self.isLoggedin = true
        }
    }
    
    var isLoggedin = false {
        didSet {
            objectWillChange.send(self)
        }
    }
}
