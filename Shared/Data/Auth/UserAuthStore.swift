//
//  UserAuthStore.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 2/1/26.
//

import Foundation
import Observation
import VIZ

@MainActor
@Observable
final class UserAuthStore {
    private(set) var login = ""
    private(set) var balance = 0.0
    private(set) var energy = 0
    private(set) var isLoggedIn = false
    private(set) var isLoading = false
    private(set) var accountMetadata: AccountMetadata? = nil
    private(set) var effectiveVestingShares = 0.0
    private(set) var dgp: API.DynamicGlobalProperties? = nil
    private(set) var isActiveKeySet: Bool = false
    private(set) var showOnboarding = false
    
    private let auth = UserAuthActor()
    
    private let vizHelper: VIZHelper = .shared
    
    init() {
        restore()
    }
    
    func showOnboarding(show: Bool) {
        showOnboarding = show
    }
    
    func makeAward(receiver: String, energy: UInt16, memo: String) async throws {
        try await auth.makeAward(receiver: receiver, energy: energy, memo: memo)
    }
    
    func makeTransfer(receiver: String, amount: Double, memo: String) async throws  {
        try await auth.makeTransfer(receiver: receiver, amount: amount, memo: memo)
    }
    
    func demoCredentials() async throws {
        let _ = try await auth.auth(login: "invite", privateKey: "5KcfoRuDfkhrLCxVcE9x51J6KN9aM9fpb78tLrvvFckxVV6FyFW")
    }
    
    func restore() {
        Task {
            let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
            guard launchedBefore else {
                UserDefaults.standard.set(true, forKey: "launchedBefore")
                try await self.demoCredentials()
                return
            }
            let creds = await auth.loadCredentials()
            guard let login = creds.login else {
                isLoggedIn = false
                return
            }
            let key = creds.activeKey ?? creds.regularKey
            guard let key else { return }
            try? await auth(login: login, key: key)
            await updateDGPData()
        }
    }
    
    func auth(login: String, key: String) async throws {
        isLoading = true
        defer { isLoading = false }

        let (account, isKeyActive) = try await auth.auth(login: login, privateKey: key)
        self.accountMetadata = try? AccountMetadata.parse(from: account.jsonMetadata)
        self.isActiveKeySet = isKeyActive
        self.balance = account.balance.resolvedAmount
        self.login = account.name
        self.energy = account.currentEnergy
        self.effectiveVestingShares = account.effectiveVestingShares
        self.isLoggedIn = true
    }
    
    func logout() {
        login = ""
        accountMetadata = nil
        isLoggedIn = false
    }
    
    func updateUserData() async {
        guard isLoggedIn, login.count > 1 else { return }
        let account = try? await vizHelper.getAccount(login: login)
        guard let account else { return }
        self.energy = account.currentEnergy
        self.effectiveVestingShares = account.effectiveVestingShares
        self.balance = account.balance.resolvedAmount
    }
    
    func updateDGPData() async {
        dgp = try? await vizHelper.getDGP()
    }
    
    func changeActiveKey(key: String) async throws {
        // TODO: verify account keyAuths
        guard VIZ.PrivateKey(key) != nil else {
            throw Errors.KeyValidationError
        }
        await auth.saveActiveKey(activeKey: key)
    }
}
