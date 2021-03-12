//
//  AwardView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 23.02.2021.
//

import SwiftUI
import VIZ
import CodeScanner

struct AwardView: View {
    private let viz = VIZHelper()
    private let energyDivider = 5.0
    @EnvironmentObject private var userAuth: UserAuth
    
    @State private var receiver = ""
    @State private var percent = 0.0
    @State private var memo = ""
    
    @State private var confettiCounter = 0
    @State private var showErrorMessage: Bool = false
    @State private var errorMessageText: String = ""
    @State private var isLoading = false
    @State private var isShowingScanner = false
    
    var body: some View {
        VStack(spacing: 10) {
            ActivityIndicator(isAnimating: $isLoading, style: .large, color: .yellow)
            
            Spacer()
            
            Text("""
                \("Account".localized()): \(userAuth.login) 🔋\(String(format: "%.2f", Double(userAuth.energy) / 100))%
                \("Social capital".localized()): \(String(format: "%.2f", userAuth.effectiveVestingShares)) Ƶ
                """)
                .padding()
                .frame(maxWidth: .infinity, alignment: Alignment.center)
                .cornerRadius(20.0)
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                TextField("Receiver".localized(), text: $receiver)
                    .padding()
                    .background(Color.themeTextField)
                    .foregroundColor(.black)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
                    .colorInvert()
                    .buttonStyle(PlainButtonStyle())
                    .onTapGesture {
                        isShowingScanner = true
                    }
                    .sheet(isPresented: $isShowingScanner, content: {
                        CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, simulatedData: "id") { result in
                            switch result {
                            case .success(let str):
                                if str.hasPrefix("viz://"), let atSymbolIdx = str.firstIndex(of: "@") {
                                    let range = str.index(after: atSymbolIdx)..<str.endIndex
                                    receiver = String(str[range])
                                    isShowingScanner = false
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    })
            }
            
            TextField("Memo".localized(), text: $memo)
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
                Text("Award".localized())
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
                    .opacity(0.95)
                    .cornerRadius(15.0)
            }
            
            ConfettiCannon(counter: $confettiCounter, confettis: [.text("Ƶ")], colors: [.red, .orange, .green], confettiSize: 20)
            
            Spacer()
        }
        .padding([.leading, .trailing], 27.5)
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear {
            let currentEnergyPercent = Double(userAuth.energy) / 100
            if percent > currentEnergyPercent {
                percent = currentEnergyPercent
            }
            if percent == 0 && currentEnergyPercent > 0 { // set initial percent value
                percent = currentEnergyPercent / energyDivider
            }
            DispatchQueue.global(qos: .background).async {
                userAuth.updateUserData()
                userAuth.updateDGPData()
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
        .alert(isPresented: $showErrorMessage) { () -> Alert in
            Alert(title: Text("Error".localized()),
                  message: Text(errorMessageText),
                  dismissButton: .default(Text("Ok"))
            )
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
        guard receiver.count > 1 else {
            return
        }
        isLoading = true
        var result: UINotificationFeedbackGenerator.FeedbackType = .error
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        viz.award(initiator: userAuth.login, regularKey: userAuth.regularKey, receiver: receiver, energy: UInt16(percent * 100), memo: memo) { error in
            if let error = error {
                errorMessageText = error.localizedDescription
                showErrorMessage = true
            } else {
                receiver = ""
                memo = ""
                confettiCounter += 1
                DispatchQueue.global(qos: .background).async {
                    userAuth.updateUserData()
                    userAuth.updateDGPData()
                    updateSlider()
                }
                result = .success
            }
            notificationFeedbackGenerator.notificationOccurred(result)
            isLoading = false
        }
    }
}

struct AwardView_Previews: PreviewProvider {
    static var previews: some View {
        AwardView().environmentObject(UserAuth())
    }
}
