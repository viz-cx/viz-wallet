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
    
    private(set) var isLoggedIn = false {
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
            updateDynamicData(account: account)
            self.login = account.name
            self.regularKey = regularKey
            self.isLoggedIn = true
        }
    }
    
    func logout() {
        self.login = ""
        self.regularKey = ""
        self.isLoggedIn = false
    }
    
    func updateUserData() {
        guard let account = viz.getAccount(login: login) else {
            return
        }
        updateDynamicData(account: account)
        DispatchQueue.main.async { [unowned self] in
            self.objectWillChange.send(self)
        }
    }
    
    func updateDGPData() {
        self.dgp = viz.getDGP()
    }
    
    func backgroundUpdate() {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            self.updateDGPData()
            self.updateUserData()
        }
    }
    
    private func updateDynamicData(account: API.ExtendedAccount) {
        self.energy = account.currentEnergy
        self.effectiveVestingShares = account.effectiveVestingShares
        self.balance = account.balance.resolvedAmount
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
