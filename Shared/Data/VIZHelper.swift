//
//  VIZHelper.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 23.02.2021.
//

import Foundation
import VIZ

struct VIZHelper {
    private let client = VIZ.Client(address: URL(string: "https://node.viz.cx")!)
    
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
