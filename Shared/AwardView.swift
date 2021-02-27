//
//  AwardView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 23.02.2021.
//

import SwiftUI
import VIZ

struct AwardView: View {
    private let viz = VIZHelper()
    @EnvironmentObject private var userAuth: UserAuth {
        didSet {
            userAuth.updateUserData()
        }
    }
    
    @State private var dgp: API.DynamicGlobalProperties? = nil
    @State private var receiver = ""
    @State private var percent = 5.0
    @State private var memo = ""
    
    @State private var confettiCounter = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Text("""
                        Account: \(userAuth.login)
                        Energy: \(String(format: "%.2f", Double(userAuth.energy) / 100)) %
                        Social capital: \(userAuth.effectiveVestingShares) Ƶ
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
                    Slider(value: $percent, in: 0.01...(Double(userAuth.energy) / 100), step: 0.01)
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
                
                Spacer()
                
                ConfettiCannon(counter: $confettiCounter, confettis: [.text("Ƶ")], confettiSize: 20)
                
            }.padding([.leading, .trailing], 27.5)
        }
    }
    
    init() {
        updateDGPData()
    }
    
    // energy multiplied by 100 (1% - 100, 100% - 10000)
    func calculateReward(energy: Int) -> Double {
        guard let dgp = dgp else {
            return 0
        }
        let voteShares = userAuth.effectiveVestingShares * 100 * Double(energy)
        let totalRewardShares = (dgp.totalRewardShares as NSString).doubleValue + voteShares
        let totalRewardFund = dgp.totalRewardFund.resolvedAmount * 1000
        let reward = ceil(totalRewardFund*voteShares/totalRewardShares) / 1000
        return reward
    }
    
    func award() {
        guard receiver.count > 1 else {
            return
        }
        viz.award(initiator: userAuth.login, regularKey: userAuth.regularKey, receiver: receiver, energy: UInt16(percent * 100), memo: memo)
        receiver = ""
        memo = ""
        confettiCounter += 1
        userAuth.updateUserData()
    }
    
    func updateDGPData() {
        guard let dgp = viz.getDGP() else {
            return
        }
        self.dgp = dgp
    }
}

struct AwardView_Previews: PreviewProvider {
    static var previews: some View {
        AwardView()
    }
}
