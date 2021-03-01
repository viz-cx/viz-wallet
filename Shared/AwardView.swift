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
    @EnvironmentObject private var userAuth: UserAuth
    
    @State private var receiver = ""
    @State private var percent = 0.0
    @State private var memo = ""
    
    @State private var confettiCounter = 0
    
    var body: some View {
        NavigationView {
            VStack {
                Text("""
                        Account: \(userAuth.login) (\(String(format: "%.2f", Double(userAuth.energy) / 100)) %)
                        Social capital: \(String(format: "%.2f", userAuth.effectiveVestingShares)) Ƶ
                        """)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: Alignment.leading)
                    .cornerRadius(20.0)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    TextField("Receiver", text: $receiver)
                        .padding()
                        .background(Color.themeTextField)
                        .foregroundColor(.black)
                        .cornerRadius(20.0)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    NavigationLink(destination: Text("QR Scanner")) {
                        Image(systemName: "qrcode.viewfinder")
                            .font(.largeTitle)
                            .colorInvert()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                TextField("Memo", text: $memo)
                    .padding()
                    .background(Color.themeTextField)
                    .foregroundColor(.black)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                VStack {
                    Slider(value: $percent, in: 0.01...100.0, step: 0.01, onEditingChanged: { changing in
                        if !changing {
                            updateSlider()
                        }
                    })
                    .accentColor(.green)
                    HStack {
                        Text(String(format: "%.2f", percent) + " %")
                            .colorInvert()
                        Text("≈\(String(format: "%.3f", calculateReward(energy: Int(percent) * 100))) Ƶ")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .colorInvert()
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
                
            }
            .padding([.leading, .trailing], 27.5)
            .background(
                LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all))
        }
        .onAppear {
            if percent == 0 {
                percent = Double(userAuth.energy) / 100
            }
            userAuth.backgroundUpdate()
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    func updateSlider() {
        let energyPercent = Double(userAuth.energy) / 100
        if percent > energyPercent {
            percent = energyPercent
        }
    }
    
    // energy multiplied by 100 (1% - 100, 100% - 10000)
    func calculateReward(energy: Int) -> Double {
        guard let dgp = userAuth.dgp else {
            return 0
        }
        let voteShares = userAuth.effectiveVestingShares * 100 * Double(energy)
        let totalRewardShares = (dgp.totalRewardShares as NSString).doubleValue + voteShares
        let totalRewardFund = dgp.totalRewardFund.resolvedAmount * 1000
        let reward = ceil(totalRewardFund*voteShares/totalRewardShares) / 1000
        return reward
    }
    
    func award() {
        var result: UINotificationFeedbackGenerator.FeedbackType = .error
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        defer {
            notificationFeedbackGenerator.notificationOccurred(result)
        }
        guard receiver.count > 1 else {
            return
        }
        result = .success
        viz.award(initiator: userAuth.login, regularKey: userAuth.regularKey, receiver: receiver, energy: UInt16(percent * 100), memo: memo)
        receiver = ""
        memo = ""
        confettiCounter += 1
        userAuth.updateUserData()
        userAuth.updateDGPData()
    }
}

struct AwardView_Previews: PreviewProvider {
    static var previews: some View {
        AwardView()
    }
}
