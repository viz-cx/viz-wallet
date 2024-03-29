//
//  TransferView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 28.02.2021.
//

import SwiftUI
import CodeScanner

struct TransferView: View {
    private let viz = VIZHelper.shared
    @State private var confettiCounter = 0
    @State private var empty = true
    
    @EnvironmentObject private var userAuth: UserAuth
    
    @State private var receiver = ""
    @State private var amount: Double? = nil
    @State private var memo = ""
    
    @State private var showErrorMessage: Bool = false
    @State private var errorMessageText: String = ""
    @State private var isLoading = false
    @State private var isShowingScanner = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                if userAuth.activeKey.isEmpty {
                    ActiveKeyView()
                } else {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("🧑 \("Account".localized()): \(userAuth.login)")
                        Text("💰 \("Liquid balance".localized()): \(VIZHelper.toFormattedString(userAuth.balance))")
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
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
                    
                    CurrencyTextField("Amount".localized(), value: $amount, alwaysShowFractions: true, numberOfDecimalPlaces: 2, currencySymbol: "Ƶ")
                        .keyboardType(UIKeyboardType.decimalPad)
                        .padding()
                        .background(Color.themeTextField)
                        .foregroundColor(.black)
                        .cornerRadius(20.0)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .onChange(of: amount) { (value) in
                            guard let value = value else { return }
                            if value > userAuth.balance {
                                self.amount = userAuth.balance
                            }
                        }
                    
                    TextField("Memo".localized(), text: $memo)
                        .padding()
                        .background(Color.themeTextField)
                        .foregroundColor(.black)
                        .cornerRadius(20.0)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    if isLoading {
                        ActivityIndicator(isAnimating: $isLoading, style: .large, color: .yellow)
                    } else {
                        Button(action: transfer) {
                            Text("Transfer".localized())
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(
                                    maxWidth: .infinity,
                                    minHeight: 50,
                                    maxHeight: 50,
                                    alignment: .center
                                )
                                .background(Color.orange)
                                .opacity(0.95)
                                .cornerRadius(15.0)
                        }
                    }
                    
                    ConfettiCannon(counter: $confettiCounter, confettis: [.text("Ƶ")], colors: [.red, .orange, .green], confettiSize: 20)
                    
                    Spacer()
                }
            }
            .padding([.leading, .trailing], 16.0)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
        .onAppear {
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
    
    func transfer() {
        guard let amount = amount else {
            return
        }
        isLoading = true
        var result: UINotificationFeedbackGenerator.FeedbackType = .error
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        viz.transfer(initiator: userAuth.login, activeKey: userAuth.activeKey, receiver: receiver, amount: amount, memo: memo) { (error) in
            if let error = error {
                errorMessageText = error.localizedDescription
                showErrorMessage = true
            } else {
                receiver = ""
                self.amount = nil
                self.empty = true
                memo = ""
                confettiCounter += 1
                DispatchQueue.global(qos: .background).async {
                    userAuth.updateUserData()
                }
                result = .success
            }
            notificationFeedbackGenerator.notificationOccurred(result)
            isLoading = false
        }
        
    }
}

struct TransferView_Previews: PreviewProvider {
    
    static let showActiveKeyPreview = true
    
    static let auth = UserAuth()
    
    init() {
        let randomKey = "5KLTkMZc3oRDAcdKeTv22sh4F2mB6rewyPDU4FENc4oYZ5DFBpe"
        if TransferView_Previews.showActiveKeyPreview {
            TransferView_Previews.auth.changeActiveKey(key: randomKey)
        }
    }
    
    static var previews: some View {
        TransferView().environmentObject(auth)
    }
}
