//
//  UserAuthActor.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 2/1/26.
//

import KeychainAccess
import VIZ

actor UserAuthActor {
    
    private let keychain = Keychain(service: "cx.viz.viz-wallet")
        .accessibility(.whenPasscodeSetThisDeviceOnly, authenticationPolicy: [.biometryAny])
        .synchronizable(true)
    
    private let viz = VIZHelper.shared
    
    func makeTransfer(receiver: String, amount: Double, memo: String) async throws {
        let (login, _, activeKey) = loadCredentials()
        guard let login, let activeKey else {
            throw Errors.SignError
        }
        try await viz.transfer(
            initiator: login,
            activeKey: activeKey,
            receiver: receiver,
            amount: amount,
            memo: memo
        )
    }
    
    func makeAward(receiver: String, energy: UInt16, memo: String) async throws {
        let (login, regularKey, _) = loadCredentials()
        guard let login, let regularKey else {
            throw Errors.SignError
        }
        try await viz.award(
            initiator: login,
            regularKey: regularKey,
            receiver: receiver,
            energy: energy,
            memo: memo
        )
    }
    
    func loadCredentials() -> (login: String?, regularKey: String?, activeKey: String?) {
        (
            try? keychain.getString("login"),
            try? keychain.getString("regularKey"),
            try? keychain.getString("activeKey")
        )
    }
    
    func save(login: String?, regularKey: String?, activeKey: String?) {
        keychain["login"] = login
        keychain["regularKey"] = regularKey
        saveActiveKey(activeKey: activeKey)
    }
    
    func saveActiveKey(activeKey: String?) {
        keychain["activeKey"] = activeKey
    }
    
    func auth(
        login: String,
        privateKey: String
    ) async throws -> (account: API.ExtendedAccount, isActive: Bool) {
        guard login.count > 1 else {
            throw Errors.LoginTooSmall
        }
        let account = try await viz.getAccount(login: login)
        guard let account = account else {
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
        
        let activeKey = isActive ? privateKey : nil
        save(login: login, regularKey: privateKey, activeKey: activeKey)
        
        return (account, isActive)
    }
}
