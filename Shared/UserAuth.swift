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
    
    var login = ""
    
    var isLoggedIn = false {
        didSet {
            objectWillChange.send(self)
        }
    }
    
    private let viz = VIZHelper()
    
    func auth(login: String, regularKey: String) {
        guard login.count > 1 else {
            print("Login too small")
            return
        }
        guard let account = viz.getAccount(login: login) else {
            return
        }
        var isRegularValid = false
        for auth in account.regularAuthority.keyAuths {
            if auth.weight >= account.regularAuthority.weightThreshold {
                guard let publicKey = PrivateKey(regularKey)?.createPublic() else {
                    continue
                }
                isRegularValid = publicKey.address == auth.value.address
                if isRegularValid {
                    break
                }
            }
        }
        if isRegularValid {
            self.login = login
            self.isLoggedIn = true
        }
    }
}
