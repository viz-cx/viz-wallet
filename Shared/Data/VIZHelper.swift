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

struct VIZHelper {
    static let shared = VIZHelper()
    
    private let client: VIZ.Client
    
    private init() {
        let address = UserDefaults.standard.string(forKey: "public_node") ?? ""
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
    
    func getAccount(login: String) -> API.ExtendedAccount? {
        let req = API.GetAccounts(names: [login])
        let result = try? client.sendSynchronous(req)
        return result?.first
    }
    
    func getDGP() -> API.DynamicGlobalProperties? {
        let req = API.GetDynamicGlobalProperties()
        let result = try? client.sendSynchronous(req)
        return result
    }
    
    func inviteRegistration(inviteSecret: String, accountName: String, password: String, callback: @escaping (_ error: Error?) -> ()) {
        client.send(API.GetDynamicGlobalProperties()) { props, error in
            guard let props = props else {
                callback(Errors.UnknownError)
                return
            }
            let expiry = props.time.addingTimeInterval(60)
            let initiator = "invite"
            let privateKey = "5KcfoRuDfkhrLCxVcE9x51J6KN9aM9fpb78tLrvvFckxVV6FyFW"
            guard let key = PrivateKey(privateKey) else {
                callback(Errors.KeyValidationError)
                return
            }
            guard let masterKey = PrivateKey(seed: accountName + "master" + password) else {
                callback(Errors.KeyValidationError)
                return
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
                callback(Errors.SignError)
                return
            }
            let trx = API.BroadcastTransaction(transaction: stx)
            client.send(trx) { res, error in
                callback(error)
            }
        }
    }
    
    func accountUpdate(accountName: String, password: String, callback: @escaping (_ error: Error?) -> ()) {
        client.send(API.GetDynamicGlobalProperties()) { props, err in
            guard let props = props, err == nil else {
                callback(Errors.UnknownError)
                return
            }
            let expiry = props.time.addingTimeInterval(60)
            let masterKey, activeKey, regularKey, memoKey: PrivateKey
            do {
                masterKey = try privateKey(fromAccount: accountName, password: password, type: .master)
                activeKey = try privateKey(fromAccount: accountName, password: password, type: .active)
                regularKey = try privateKey(fromAccount: accountName, password: password, type: .regular)
                memoKey = try privateKey(fromAccount: accountName, password: password, type: .memo)
            } catch {
                callback(error)
                return
            }
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
                callback(Errors.SignError)
                return
            }
            let trx = API.BroadcastTransaction(transaction: stx)
            client.send(trx) { res, error in
                callback(error)
            }
        }
    }
    
    func award(initiator: String, regularKey: String, receiver: String, energy: UInt16, memo: String, beneficiaries: [VIZ.Operation.Beneficiary] = [], callback: @escaping (Error?) -> ()) {
        client.send(API.GetDynamicGlobalProperties()) { props, error in
            guard let props = props else {
                callback(Errors.UnknownError)
                return
            }
            let expiry = props.time.addingTimeInterval(60)
            guard let key = PrivateKey(regularKey) else {
                callback(Errors.KeyValidationError)
                return
            }
            let award = VIZ.Operation.Award(initiator: initiator, receiver: receiver, energy: energy, customSequence: 0, memo: memo, beneficiaries: beneficiaries)
            let tx = Transaction(
                refBlockNum: UInt16(props.headBlockNumber & 0xFFFF),
                refBlockPrefix: props.headBlockId.prefix,
                expiration: expiry,
                operations: [award]
            )
            guard let stx = try? tx.sign(usingKey: key) else {
                callback(Errors.SignError)
                return
            }
            let trx = API.BroadcastTransaction(transaction: stx)
            client.send(trx) { res, error in
                callback(error)
            }
        }
    }
    
    func transfer(initiator: String, activeKey: String, receiver: String, amount: Double, memo: String, callback: @escaping (Error?) -> ()) {
        client.send(API.GetDynamicGlobalProperties()) { props, error in
            guard let props = props else {
                callback(Errors.UnknownError)
                return
            }
            let expiry = props.time.addingTimeInterval(60)
            guard let key = PrivateKey(activeKey) else {
                callback(Errors.KeyValidationError)
                return
            }
            let transfer = VIZ.Operation.Transfer(from: initiator, to: receiver, amount: Asset(amount), memo: memo)
            let tx = Transaction(
                refBlockNum: UInt16(props.headBlockNumber & 0xFFFF),
                refBlockPrefix: props.headBlockId.prefix,
                expiration: expiry,
                operations: [transfer]
            )
            guard let stx = try? tx.sign(usingKey: key) else {
                callback(Errors.SignError)
                return
            }
            let trx = API.BroadcastTransaction(transaction: stx)
            client.send(trx) { res, error in
                callback(error)
            }
        }
    }
}
