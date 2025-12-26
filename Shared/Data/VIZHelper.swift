//
//  VIZHelper.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 23.02.2021.
//

import Foundation
import VIZ

enum VIZKeyType: String {
    case regular
    case active
    case master
    case memo
}

actor VIZHelper {
    static let shared = VIZHelper()
    
    private let client: VIZ.Client
    
    private init() {
        let address = UserDefaults.standard.string(forKey: "public_node") ?? "https://node.viz.cx"
        self.client = VIZ.Client(address: URL(string: address)!)
    }
    
    static func toFormattedString(_ amount: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.numberStyle = NumberFormatter.Style.currency
        numberFormatter.currencySymbol = "Ƶ"
        return numberFormatter.string(from: amount as NSNumber) ?? ""
    }
    
    func privateKey(fromAccount name: String, password: String, type: VIZKeyType) throws -> PrivateKey {
        guard let key = PrivateKey(seed: name + type.rawValue + password) else {
            throw Errors.KeyValidationError
        }
        return key
    }
    
    func getAccount(login: String) async -> API.ExtendedAccount? {
        let req = API.GetAccounts(names: [login])
        let result = try? await client.send(req)
        return result?.first
    }
    
    func getDGP() async -> API.DynamicGlobalProperties? {
        let req = API.GetDynamicGlobalProperties()
        let result = try? await client.send(req)
        return result
    }
    
    func inviteRegistration(inviteSecret: String, accountName: String, password: String) async throws {
        let props = try await client.send(API.GetDynamicGlobalProperties())
        let expiry = props.time.addingTimeInterval(60)
        let initiator = "invite"
        let privateKey = "5KcfoRuDfkhrLCxVcE9x51J6KN9aM9fpb78tLrvvFckxVV6FyFW"
        guard let key = PrivateKey(privateKey) else {
            throw Errors.KeyValidationError
        }
        guard let masterKey = PrivateKey(seed: accountName + "master" + password) else {
            throw Errors.KeyValidationError
        }
        let masterPublicKey = masterKey.createPublic()
        let inviteRegistration = VIZ.Operation.InviteRegistration(initiator: initiator, newAccountName: accountName, inviteSecret: inviteSecret, newAccountKey: masterPublicKey)
        let tx = Transaction(
            refBlockNum: UInt16(props.headBlockNumber & 0xFFFF),
            refBlockPrefix: props.headBlockId.prefix,
            expiration: expiry,
            operations: [inviteRegistration]
        )
        guard let stx = try? tx.sign(usingKey: key) else {
            throw Errors.SignError
        }
        let trx = API.BroadcastTransaction(transaction: stx)
        let _ = try await client.send(trx)
    }
    
    func accountUpdate(accountName: String, password: String) async throws {
        let props = try await client.send(API.GetDynamicGlobalProperties())
        let expiry = props.time.addingTimeInterval(60)
        
        let masterKey, activeKey, regularKey, memoKey: PrivateKey
        masterKey = try privateKey(fromAccount: accountName, password: password, type: .master)
        activeKey = try privateKey(fromAccount: accountName, password: password, type: .active)
        regularKey = try privateKey(fromAccount: accountName, password: password, type: .regular)
        memoKey = try privateKey(fromAccount: accountName, password: password, type: .memo)
        
        let masterAuthority = Authority(keyAuths: [Authority.Auth(masterKey.createPublic())])
        let activeAuthority = Authority(keyAuths: [Authority.Auth(activeKey.createPublic())])
        let regularAuthority = Authority(keyAuths: [Authority.Auth(regularKey.createPublic())])
        let memoPublicKey = memoKey.createPublic()
        
        let accountUpdate = VIZ.Operation.AccountUpdate(account: accountName, master: masterAuthority, active: activeAuthority, regular: regularAuthority, memoKey: memoPublicKey)
        let tx = Transaction(
            refBlockNum: UInt16(props.headBlockNumber & 0xFFFF),
            refBlockPrefix: props.headBlockId.prefix,
            expiration: expiry,
            operations: [accountUpdate]
        )
        guard let stx = try? tx.sign(usingKey: masterKey) else {
            throw Errors.SignError
        }
        let trx = API.BroadcastTransaction(transaction: stx)
        let _ = try await client.send(trx)
    }
    
    func award(initiator: String, regularKey: String, receiver: String, energy: UInt16, memo: String, beneficiaries: [VIZ.Operation.Beneficiary] = []) async throws {
        let props = try await client.send(API.GetDynamicGlobalProperties())
        
        let expiry = props.time.addingTimeInterval(60)
        guard let key = PrivateKey(regularKey) else {
            throw Errors.KeyValidationError
        }
        let award = VIZ.Operation.Award(initiator: initiator, receiver: receiver, energy: energy, customSequence: 0, memo: memo, beneficiaries: beneficiaries)
        let tx = Transaction(
            refBlockNum: UInt16(props.headBlockNumber & 0xFFFF),
            refBlockPrefix: props.headBlockId.prefix,
            expiration: expiry,
            operations: [award]
        )
        guard let stx = try? tx.sign(usingKey: key) else {
            throw Errors.SignError
        }
        let trx = API.BroadcastTransaction(transaction: stx)
        let _ = try await client.send(trx)
    }
    
    func transfer(initiator: String, activeKey: String, receiver: String, amount: Double, memo: String) async throws {
        let props = try await client.send(API.GetDynamicGlobalProperties())
        let expiry = props.time.addingTimeInterval(60)
        guard let key = PrivateKey(activeKey) else {
            throw Errors.KeyValidationError
        }
        let transfer = VIZ.Operation.Transfer(from: initiator, to: receiver, amount: Asset(amount), memo: memo)
        let tx = Transaction(
            refBlockNum: UInt16(props.headBlockNumber & 0xFFFF),
            refBlockPrefix: props.headBlockId.prefix,
            expiration: expiry,
            operations: [transfer]
        )
        guard let stx = try? tx.sign(usingKey: key) else {
            throw Errors.SignError
        }
        let trx = API.BroadcastTransaction(transaction: stx)
        let _ = try await client.send(trx)
    }
}
