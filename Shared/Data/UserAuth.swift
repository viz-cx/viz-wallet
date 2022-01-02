//
//  UserAuth.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 22.02.2021.
//

import Combine
import Foundation
import VIZ
import KeychainAccess

class UserAuth: ObservableObject {
    internal let objectWillChange = PassthroughSubject<UserAuth,Never>()
    
    private let keychain = Keychain(service: "cx.viz.viz-wallet")
        .synchronizable(true)
    
    // Login used for registration
    var registrationLogin: String = "" {
        didSet {
            keychain["registrationLogin"] = registrationLogin
            updateObject()
        }
    }
    // Random password for generate private keys
    var registrationPassword: String {
        if let password = try? keychain.getString("registrationPassword") {
            return password
        } else {
            // password must be generated only once!
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let length = Int.random(in: 512...1024)
            let randomPassword = String((0..<length).map {_ in letters.randomElement()! })
            keychain["registrationPassword"] = randomPassword
            return randomPassword
        }
    }
    
    private(set) var login: String = "" {
        didSet {
            if login != "" {
                keychain["login"] = login
            } else {
                keychain["login"] = nil
            }
        }
    }
    private(set) var regularKey: String = "" {
        didSet {
            if regularKey != "" {
                keychain["regularKey"] = regularKey
            } else {
                keychain["regularKey"] = nil
            }
        }
    }
    private(set) var activeKey: String = "" {
        didSet {
            if activeKey != "" {
                keychain["activeKey"] = activeKey
            } else {
                keychain["activeKey"] = nil
            }
        }
    }
    private(set) var energy = 0
    private(set) var effectiveVestingShares = 0.0
    private(set) var balance = 0.0
    private(set) var dgp: API.DynamicGlobalProperties? = nil
    private(set) var isLoggedIn = false
    
    private(set) var accountNickname = ""
    private(set) var accountAbout = ""
    private(set) var accountAvatar = ""
    
    private(set) var showOnboarding = false
    
    private let viz = VIZHelper.shared
    
    init() {
        let login = try? keychain.getString("login")
        let regularKey = try? keychain.getString("regularKey")
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            if login == nil || login == "" {
                demoCredentials()
            }
        }
        if let registrationLogin = try? keychain.getString("registrationLogin") {
            self.registrationLogin = registrationLogin
        }
        if let activeKey = try? keychain.getString("activeKey") {
            self.activeKey = activeKey
        }
        if let login = login, let regularKey = regularKey {
            auth(login: login, privateKey: regularKey, callback: {_ in})
            updateDGPData()
        }
    }
    
    func showOnboarding(show: Bool) {
        showOnboarding = show
        updateObject()
    }
    
    func auth(login: String, privateKey: String, callback: @escaping (Error?) -> ()) {
        DispatchQueue.global(qos: .background).async { [unowned self] in
            guard login.count > 1 else {
                callback(Errors.LoginTooSmall)
                return
            }
            guard let account = viz.getAccount(login: login) else {
                callback(Errors.WrongAccountName)
                return
            }
            var isActiveValid = false
            for auth in account.activeAuthority.keyAuths where auth.weight >= account.activeAuthority.weightThreshold {
                guard let publicKey = PrivateKey(privateKey)?.createPublic() else {
                    continue
                }
                isActiveValid = publicKey.address == auth.value.address
                if isActiveValid {
                    break
                }
            }
            var isRegularValid = false
            for auth in account.regularAuthority.keyAuths where auth.weight >= account.regularAuthority.weightThreshold {
                guard let publicKey = PrivateKey(privateKey)?.createPublic() else {
                    continue
                }
                isRegularValid = publicKey.address == auth.value.address
                if isRegularValid {
                    break
                }
            }
            if isActiveValid {
                self.activeKey = privateKey
            }
            if isActiveValid || isRegularValid {
                updateDynamicData(account: account)
                self.login = account.name
                self.regularKey = privateKey
                self.isLoggedIn = true
                
                let decoder = JSONDecoder()
                let metadata = account.jsonMetadata
                    .replacingOccurrences(of: "sia://", with: "https://siasky.net/")
                let json = metadata.data(using: .utf8) ?? Data()
                let meta = try? decoder.decode(AccountMetadata.self, from: json)
                if let nickname = meta?.profile.nickname, nickname.count > 0 {
                    accountNickname = nickname
                } else {
                    accountNickname = login
                }
                if let about = meta?.profile.about, about.count > 0 {
                    accountAbout = about
                } else {
                    let formatter1 = DateFormatter()
                    formatter1.dateStyle = .short
                    let created = formatter1.string(from: account.created)
                    accountAbout = String(format: "Account сreated at %@".localized(), created)
                }
                accountAvatar = meta?.profile.avatar ?? ""
                
                callback(nil)
                updateObject()
            } else {
                callback(Errors.KeyValidationError)
                logout()
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
        login = ""
        regularKey = ""
        activeKey = ""
        isLoggedIn = false
        updateObject()
    }
    
    func demoCredentials() {
        auth(login: "invite", privateKey: "5KcfoRuDfkhrLCxVcE9x51J6KN9aM9fpb78tLrvvFckxVV6FyFW", callback: {_ in})
    }
    
    func updateUserData() {
        guard isLoggedIn, login.count > 1, let account = viz.getAccount(login: login) else {
            return
        }
        updateDynamicData(account: account)
        updateObject()
    }
    
    func updateDGPData() {
        dgp = viz.getDGP()
        updateObject()
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
