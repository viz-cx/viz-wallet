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
        client = VIZ.Client(address: URL(string: address)!)
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
    
    func getAccount(login: String) async throws -> API.ExtendedAccount? {
        let req = API.GetAccount(account: login, customProtocolId: "")
        let result = try await client.send(req)
        return result
    }
    
    func getDGP() async throws -> API.DynamicGlobalProperties? {
        let req = API.GetDynamicGlobalProperties()
        return try await client.send(req)
    }
    
    func inviteRegistration(inviteSecret: String, accountName: String, password: String) async throws {
        guard let props = try await getDGP() else {
            throw Errors.UnknownError
        }
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
    
    struct Witness: Decodable, Sendable {
        let id: Int
        let owner: String
        let created: Date
        let url: String
        let votes: VIZ.API.Share?
        let penaltyPercent: Int?
        let countedVotes: VIZ.API.Share?
        let virtualLastUpdate: VIZ.API.Share?
        let virtualPosition: VIZ.API.Share?
        let virtualScheduledTime: VIZ.API.Share?
        let totalMissed: Int?
        let lastAslot: Int?
        let lastConfirmedBlockNum: Int?
        let signingKey: String?
        let props: WitnessProps?
        let lastWork: String?
        let runningVersion: String?
        let hardforkVersionVote: String?
        let hardforkTimeVote: Date?
        
        enum CodingKeys: String, CodingKey {
            case id
            case owner
            case created
            case url
            case votes
            case penaltyPercent = "penalty_percent"
            case countedVotes = "counted_votes"
            case virtualLastUpdate = "virtual_last_update"
            case virtualPosition = "virtual_position"
            case virtualScheduledTime = "virtual_scheduled_time"
            case totalMissed = "total_missed"
            case lastAslot = "last_aslot"
            case lastConfirmedBlockNum = "last_confirmed_block_num"
            case signingKey = "signing_key"
            case props
            case lastWork = "last_work"
            case runningVersion = "running_version"
            case hardforkVersionVote = "hardfork_version_vote"
            case hardforkTimeVote = "hardfork_time_vote"
        }
    }
    
    struct WitnessProps: Decodable, Sendable {
        let accountCreationFee: VIZ.Asset?
        let maximumBlockSize: Int?
        let createAccountDelegationRatio: Int?
        let createAccountDelegationTime: Int?
        let minDelegation: VIZ.Asset?
        let minCurationPercent: Int?
        let maxCurationPercent: Int?
        let bandwidthReservePercent: Int?
        let bandwidthReserveBelow: VIZ.Asset?
        let flagEnergyAdditionalCost: Int?
        let voteAccountingMinRshares: Int?
        let committeeRequestApproveMinPercent: Int?
        let inflationWitnessPercent: Int?
        let inflationRatioCommitteeVsRewardFund: Int?
        let inflationRecalcPeriod: Int?
        let dataOperationsCostAdditionalBandwidth: Int?
        let witnessMissPenaltyPercent: Int?
        let witnessMissPenaltyDuration: Int?
        let createInviteMinBalance: VIZ.Asset?
        let committeeCreateRequestFee: VIZ.Asset?
        let createPaidSubscriptionFee: VIZ.Asset?
        let accountOnSaleFee: VIZ.Asset?
        let subaccountOnSaleFee: VIZ.Asset?
        let witnessDeclarationFee: VIZ.Asset?
        let withdrawIntervals: Int?
        
        enum CodingKeys: String, CodingKey {
            case accountCreationFee = "account_creation_fee"
            case maximumBlockSize = "maximum_block_size"
            case createAccountDelegationRatio = "create_account_delegation_ratio"
            case createAccountDelegationTime = "create_account_delegation_time"
            case minDelegation = "min_delegation"
            case minCurationPercent = "min_curation_percent"
            case maxCurationPercent = "max_curation_percent"
            case bandwidthReservePercent = "bandwidth_reserve_percent"
            case bandwidthReserveBelow = "bandwidth_reserve_below"
            case flagEnergyAdditionalCost = "flag_energy_additional_cost"
            case voteAccountingMinRshares = "vote_accounting_min_rshares"
            case committeeRequestApproveMinPercent = "committee_request_approve_min_percent"
            case inflationWitnessPercent = "inflation_witness_percent"
            case inflationRatioCommitteeVsRewardFund = "inflation_ratio_committee_vs_reward_fund"
            case inflationRecalcPeriod = "inflation_recalc_period"
            case dataOperationsCostAdditionalBandwidth = "data_operations_cost_additional_bandwidth"
            case witnessMissPenaltyPercent = "witness_miss_penalty_percent"
            case witnessMissPenaltyDuration = "witness_miss_penalty_duration"
            case createInviteMinBalance = "create_invite_min_balance"
            case committeeCreateRequestFee = "committee_create_request_fee"
            case createPaidSubscriptionFee = "create_paid_subscription_fee"
            case accountOnSaleFee = "account_on_sale_fee"
            case subaccountOnSaleFee = "subaccount_on_sale_fee"
            case witnessDeclarationFee = "witness_declaration_fee"
            case withdrawIntervals = "withdraw_intervals"
        }
        
    }

    
    func getWitnessesByVote() async throws -> [Witness] {
        struct GetWitnessesByVote: VIZ.Request {
            typealias Response = [Witness]
            public let method = "get_witnesses_by_vote"
            public var params: RequestParams<AnyEncodable>? {
                return RequestParams([AnyEncodable(self.from), AnyEncodable(self.limit)])
            }
            
            public var from: String
            public var limit: Int
            public init(fromWitness: String = "", limit: Int = 100) {
                self.from = fromWitness
                self.limit = limit > 100 ? 100 : limit
            }
        }
        return try await client.send(GetWitnessesByVote())
    }
}
