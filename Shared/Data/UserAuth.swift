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

struct AccountMetadata: Codable {
    let profile: Profile
    
    struct Profile: Codable {
        let nickname: String?
        let about: String?
        let gender: String?
        let avatar: String?
        let location: String?
        let interests: [String]?
        let site: String?
        let services: Services?
        
        struct Services: Codable {
            let telegram: String?
        }
    }
}

final class UserAuth: ObservableObject {
    private let keychain = Keychain(service: "cx.viz.viz-wallet")
        .synchronizable(true)
    
    // Login used for registration
    var registrationLogin: String = "" {
        didSet {
            keychain["registrationLogin"] = registrationLogin
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
            let randomPassword = String((0..<length).map { _ in letters.randomElement()! })
            keychain["registrationPassword"] = randomPassword
            return randomPassword
        }
    }
    
    @Published private(set) var login: String = "" {
        didSet {
            if login != "" {
                keychain["login"] = login
            } else {
                keychain["login"] = nil
            }
        }
    }
    @Published private(set) var regularKey: String = "" {
        didSet {
            if regularKey != "" {
                keychain["regularKey"] = regularKey
            } else {
                keychain["regularKey"] = nil
            }
        }
    }
    @Published private(set) var activeKey: String = "" {
        didSet {
            if activeKey != "" {
                keychain["activeKey"] = activeKey
            } else {
                keychain["activeKey"] = nil
            }
        }
    }
    @Published private(set) var energy = 0
    @Published private(set) var effectiveVestingShares = 0.0
    @Published private(set) var balance = 0.0
    @Published private(set) var dgp: API.DynamicGlobalProperties? = nil
    @Published private(set) var isLoggedIn = false
    
    @Published private(set) var accountMetadata: AccountMetadata? = nil
    
    @Published private(set) var showOnboarding = false
    
    @Published private(set) var isLoading = false
    
    private let viz = VIZHelper.shared
    
    init() {
        let login = try? keychain.getString("login")
        let regularKey = try? keychain.getString("regularKey")
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            if login == nil || login == "" {
                Task {
                    await demoCredentials()
                }
            }
        }
        if let registrationLogin = try? keychain.getString("registrationLogin") {
            self.registrationLogin = registrationLogin
        }
        if let activeKey = try? keychain.getString("activeKey") {
            self.activeKey = activeKey
        }
        if let login = login, let regularKey = regularKey {
            Task {
                try? await auth(login: login, privateKey: regularKey)
                await updateDGPData()
            }
        }
    }
    
    func showOnboarding(show: Bool) {
        showOnboarding = show
    }
    
    func auth(login: String, privateKey: String) async throws {
        try await withLoading {
            guard login.count > 1 else {
                throw Errors.LoginTooSmall
            }
            
            let (account, isActiveValid) = try await self.fetchAndValidateAccount(
                login: login,
                privateKey: privateKey
            )
            
            // We’re already on @MainActor; keep assignments here.
            if isActiveValid {
                self.activeKey = privateKey
            }
            self.login = account.name
            self.regularKey = privateKey
            self.accountMetadata = try? self.parseAccountMetadata(
                from: account.jsonMetadata
            )
            self.isLoggedIn = true
            self.updateDynamicData(account: account)
        }
    }

    
    private func fetchAndValidateAccount(
        login: String,
        privateKey: String
    ) async throws -> (account: API.ExtendedAccount, isActive: Bool) {
        
        guard let account = await viz.getAccount(login: login) else {
            throw Errors.WrongAccountName
        }
        
        guard let publicKey = PrivateKey(privateKey)?.createPublic() else {
            throw Errors.KeyValidationError
        }
        
        let isActive = account.activeAuthority.keyAuths.contains {
            $0.weight >= account.activeAuthority.weightThreshold &&
            $0.value.address == publicKey.address
        }
        
        let isRegular = account.regularAuthority.keyAuths.contains {
            $0.weight >= account.regularAuthority.weightThreshold &&
            $0.value.address == publicKey.address
        }
        
        guard isActive || isRegular else {
            throw Errors.KeyValidationError
        }
        
        return (account, isActive)
    }

    
    func changeActiveKey(key: String) {
        // TODO: verify account keyAuths
        guard VIZ.PrivateKey(key) != nil else { return }
        activeKey = key
    }
    
    func logout() {
        login = ""
        regularKey = ""
        activeKey = ""
        accountMetadata = nil
        isLoggedIn = false
    }
    
    func demoCredentials() async {
        try? await auth(login: "invite", privateKey: "5KcfoRuDfkhrLCxVcE9x51J6KN9aM9fpb78tLrvvFckxVV6FyFW")
    }
    
    func updateUserData() async {
        await withLoading {
            guard self.isLoggedIn, self.login.count > 1 else { return }
            guard let account = await self.viz.getAccount(login: self.login) else { return }
            self.updateDynamicData(account: account)
        }
    }
    
    func updateDGPData() async {
        let dgp = await viz.getDGP()
        self.dgp = dgp
    }
    
    private func updateDynamicData(account: API.ExtendedAccount) {
        self.energy = account.currentEnergy
        self.effectiveVestingShares = account.effectiveVestingShares
        self.balance = account.balance.resolvedAmount
    }
    
    private func parseAccountMetadata(from jsonString: String) throws -> AccountMetadata {
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw Errors.KeyValidationError
        }
        return try JSONDecoder().decode(AccountMetadata.self, from: jsonData)
    }
    
    private func withLoading<T>(
        _ operation: @escaping () async throws -> T
    ) async rethrows -> T {
        isLoading = true
        
        defer {
            Task { @MainActor in
                isLoading = false
            }
        }
        
        return try await operation()
    }
}

