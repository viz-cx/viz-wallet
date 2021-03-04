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
    
    private(set) var login = ""
    private(set) var regularKey = ""
    private(set) var activeKey = ""
    private(set) var energy = 0
    private(set) var effectiveVestingShares = 0.0
    private(set) var balance = 0.0
    private(set) var dgp: API.DynamicGlobalProperties? = nil
    private(set) var isLoggedIn = false
    
    private let viz = VIZHelper()
    
    func auth(login: String, regularKey: String) {
        DispatchQueue.global(qos: .background).async { [unowned self] in
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
                updateDynamicData(account: account)
                self.login = account.name
                self.regularKey = regularKey
                self.isLoggedIn = true
                updateObject()
            }
        }
    }
    
    func changeActiveKey(key: String) {
        // TODO: verify account keyAuths
        guard VIZ.PrivateKey(key) != nil else { return }
        activeKey = key
        updateObject()
    }
    
    func logout() {
        self.login = ""
        self.regularKey = ""
        self.isLoggedIn = false
        updateObject()
    }
    
    func updateUserData() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            guard isLoggedIn, login.count > 1, let account = viz.getAccount(login: login) else {
                return
            }
            self.updateDynamicData(account: account)
            self.updateObject()
        }
    }
    
    func updateDGPData() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            self.dgp = viz.getDGP()
            self.updateObject()
        }
    }
    
    private func updateDynamicData(account: API.ExtendedAccount) {
        self.energy = account.currentEnergy
        self.effectiveVestingShares = account.effectiveVestingShares
        self.balance = account.balance.resolvedAmount
    }
    
    private func updateObject() {
        DispatchQueue.main.async { [unowned self] in
            self.objectWillChange.send(self)
        }
    }
}

fileprivate extension API.ExtendedAccount {
    var effectiveVestingShares: Double {
        return vestingShares.resolvedAmount
            + receivedVestingShares.resolvedAmount
            - delegatedVestingShares.resolvedAmount
    }
    
    var currentEnergy: Int {
        let deltaTime = Date().timeIntervalSince(lastVoteTime)
        var e = Float64(energy) + (deltaTime * 10000 / 432000) //CHAIN_ENERGY_REGENERATION_SECONDS
        if e > 10000 {
            e = 10000
        }
        return Int(e)
    }
}
