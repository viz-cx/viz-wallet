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
    private let viz = VIZHelper.shared
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
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                Spacer()
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("🧑 \("Login".localized()): \(userAuth.login)")
                    Text("🔋 \("Energy".localized()): \(String(format: "%.2f", Double(userAuth.energy) / 100))%")
                    Text("🏆 \("Social capital".localized()): \( VIZHelper.toFormattedString(userAuth.effectiveVestingShares))")
                        .lineLimit(1)
                        .fixedSize()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .cornerRadius(20.0)
                .font(.headline)
                .foregroundColor(.white)
                
                ReceiverView(isShowingScanner: $isShowingScanner, receiver: $receiver)
                
                TextField("Memo".localized(), text: $memo)
                    .padding()
                    .background(Color.themeTextField)
                    .foregroundColor(.black)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                VStack {
                    Slider(value: $percent, in: 0.01...Double(userAuth.energy) / 100.0, step: 0.01, onEditingChanged: { changing in
                        if !changing {
                            updateSlider()
                        }
                    })
                    .accentColor(.green)
                    HStack {
                        Text(String(format: "%.2f", percent) + " %")
                            .colorInvert()
                        Text("≈\(String(format: "%.3f", calculateReward(energy: Int(percent * 100)))) Ƶ")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .colorInvert()
                    }
                }
                
                if isLoading {
                    ActivityIndicator(isAnimating: $isLoading, style: .large, color: .yellow)
                } else {
                    Button(action: {
                        Task {
                            await award()
                        }}) {
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
                }
                Spacer()
            }
            .confetti(trigger: $confettiCounter)
            .padding([.leading, .trailing], 16.0)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
        .onAppear(perform: updateCurrentPercent)
        .onTapGesture {
            hideKeyboard()
        }
        .alert(isPresented: $showErrorMessage) { () -> Alert in
            Alert(title: Text("Error".localized()),
                  message: Text(errorMessageText),
                  dismissButton: .default(Text("Ok"))
            )
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            updateCurrentPercent()
        }
    }
    
    private func updateCurrentPercent() {
        let currentEnergyPercent = Double(userAuth.energy) / 100
        if percent > currentEnergyPercent {
            percent = currentEnergyPercent
        }
        if percent == 0 && currentEnergyPercent > 0 { // set initial percent value
            if currentEnergyPercent > 1 {
                percent = round(currentEnergyPercent / energyDivider)
            } else {
                percent = round(currentEnergyPercent / energyDivider * 10) / 10.0
            }
        }
        Task {
            await userAuth.updateUserData()
            await userAuth.updateDGPData()
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
    
    func award() async {
        guard receiver.count > 1 else {
            return
        }
        isLoading = true
        var result: UINotificationFeedbackGenerator.FeedbackType = .error
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        guard percent > 0 else {
            errorMessageText = "Percent can't be less than zero".localized()
            showErrorMessage = true
            notificationFeedbackGenerator.notificationOccurred(result)
            isLoading = false
            return
        }
        do {
            try await viz.award(initiator: userAuth.login, regularKey: userAuth.regularKey, receiver: receiver, energy: UInt16(percent * 100), memo: memo)
            receiver = ""
            memo = ""
            confettiCounter += 1
            Task {
                await userAuth.updateUserData()
                await userAuth.updateDGPData()
                updateSlider()
            }
            result = .success
        } catch Client.Error.networkError(let message, _) where message.contains("502") {
            let account = try? await viz.getAccount(login: receiver)
            if account == nil {
                errorMessageText = "There is no account with this login"
            } else {
                errorMessageText = message
            }
            showErrorMessage = true
        } catch {
            errorMessageText = error.localizedDescription
            showErrorMessage = true
        }
        notificationFeedbackGenerator.notificationOccurred(result)
        isLoading = false
    }
}

struct AwardView_Previews: PreviewProvider {
    static var previews: some View {
        AwardView().environmentObject(UserAuth())
    }
}
