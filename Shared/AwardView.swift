//
//  AwardView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 23.02.2021.
//

import SwiftUI
import VIZ

class AwardState: ObservableObject {
    @Published var login = ""
    @Published var energyPercent = 0.0
    @Published var effectiveVestingShares = 0.0
    @Published var dgp: API.DynamicGlobalProperties? = nil
}

struct AwardView: View {
    private let viz = VIZHelper()
    
    @ObservedObject var state = AwardState()
    
    @State private var receiver = ""
    @State private var percent = 5.0
    @State private var memo = ""
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .leading, spacing: 15) {
                    Text("""
                        Account: \(state.login)
                        Energy: \(String(format: "%.2f", state.energyPercent)) %
                        Social capital: \(state.effectiveVestingShares) Ƶ
                        """)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: Alignment.leading)
                        .cornerRadius(20.0)
                        .font(.headline)
                        .foregroundColor(.white)
                        .background(Color.orange)
                    
                    HStack {
                        TextField("Receiver", text: $receiver)
                            .padding()
                            .background(Color.themeTextField)
                            .cornerRadius(20.0)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                        NavigationLink(destination: Text("QR Scanner")) {
                            Image(systemName: "qrcode.viewfinder").font(.largeTitle)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    
                    TextField("Memo", text: $memo)
                        .padding()
                        .background(Color.themeTextField)
                        .cornerRadius(20.0)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    VStack {
                        Slider(value: $percent, in: 0.01...100.0, step: 0.01)
                        HStack {
                            Text(String(format: "%.2f", percent) + " %")
                            Text("≈\(String(format: "%.3f", calculateReward(energy: Int(percent) * 100))) Ƶ")
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                    }
                    
                    Button(action: award) {
                        Text("Award")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(
                                maxWidth: .infinity,
                                minHeight: 50,
                                maxHeight: 50,
                                alignment: .center
                            )
                            .background(Color.green)
                            .cornerRadius(15.0)
                    }
                    
                }.padding([.leading, .trailing], 27.5)
            }
        }
    }
    
    init(login: String) {
        state.login = login
        updateDGPData()
        updateAccountData()
    }
    
    // energy multiplied by 100 (1% - 100, 100% - 10000)
    func calculateReward(energy: Int) -> Double {
        guard let dgp = state.dgp else {
            return 0
        }
        let voteShares = state.effectiveVestingShares * 100 * Double(energy)
        let totalRewardShares = (dgp.totalRewardShares as NSString).doubleValue + voteShares
        let totalRewardFund = dgp.totalRewardFund.resolvedAmount * 1000
        let reward = ceil(totalRewardFund*voteShares/totalRewardShares) / 1000
        return reward
    }
    
    func award() {
        print("make award")
        updateAccountData()
    }
    
    func updateAccountData() {
        guard let account = viz.getAccount(login: state.login) else {
            return
        }
        state.energyPercent = Double(account.currentEnergy) / 100
        state.effectiveVestingShares = account.effectiveVestingShares
    }
    
    func updateDGPData() {
        guard let dgp = viz.getDGP() else {
            return
        }
        state.dgp = dgp
    }
}

extension API.ExtendedAccount {
    public var effectiveVestingShares: Double {
        return vestingShares.resolvedAmount
            + receivedVestingShares.resolvedAmount
            - delegatedVestingShares.resolvedAmount
    }
    
    public var currentEnergy: Int {
        let deltaTime = Date().timeIntervalSince(lastVoteTime)
        var e = Float64(energy) + (deltaTime * 10000 / 432000) //CHAIN_ENERGY_REGENERATION_SECONDS
        if e > 10000 {
            e = 10000
        }
        return Int(e)
    }
}

struct AwardView_Previews: PreviewProvider {
    static var previews: some View {
        AwardView(login: "example")
    }
}
