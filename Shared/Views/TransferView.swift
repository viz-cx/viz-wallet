//
//  TransferView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 28.02.2021.
//

import SwiftUI

struct TransferView: View {
    private let viz = VIZHelper()
    @State private var confettiCounter = 0
    @State private var empty = true
    
    @EnvironmentObject private var userAuth: UserAuth
    
    @State private var receiver = ""
    @State private var amount: Double? = nil
    @State private var memo = ""
    
    @State private var showErrorMessage: Bool = false
    @State private var errorMessageText: String = ""
    @State private var isLoading = false
    @State private var tmpActiveKey = ""
    
    private var currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimum = 0
        formatter.isPartialStringValidationEnabled = true
        formatter.isLenient = true
        return formatter
    }()
    
    var body: some View {
        let binding = Binding<String>(get: {
            if empty { return "" }
            let value = self.amount ?? 0.0
            let dot = Locale.current.decimalSeparator ?? "."
            var s = String(format: "%f", value)
                .replacingOccurrences(of: ".", with: dot)
                .reversed()
                .drop(while: { $0 == "0" })
                .reversed()
                .map(String.init)
                .joined()
            if let last = s.last, String(last) == dot {
                s.removeLast()
            }
            return s
        }, set: { (str) in
            empty = str.isEmpty
            let dot = Locale.current.decimalSeparator ?? "."
            let s = str.replacingOccurrences(of: dot, with: ".")
            let amount = Double(s) ?? 0.0
            self.amount = (amount >= userAuth.balance) ? userAuth.balance : amount
        })
        VStack {
            if userAuth.activeKey.isEmpty {
                Spacer()
                
                Text("Active key is empty")
                    .padding()
                    .frame(maxWidth: .infinity, alignment: Alignment.center)
                    .cornerRadius(20.0)
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextField("Private active key", text: $tmpActiveKey)
                    .padding()
                    .background(Color.themeTextField)
                    .foregroundColor(.black)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                Button(action: submitActiveKey) {
                    Text("Submit")
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
                
                Spacer()
            } else {
                ActivityIndicator(isAnimating: $isLoading, style: .large, color: .yellow)
                
                Text("""
                    Account: \(userAuth.login)
                    Liquid balance: \(String(format: "%.3f", userAuth.balance)) Ƶ
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
                
                TextField("Amount", text: binding)
                    .keyboardType(UIKeyboardType.decimalPad)
                    .padding()
                    .background(Color.themeTextField)
                    .foregroundColor(.black)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                TextField("Memo", text: $memo)
                    .padding()
                    .background(Color.themeTextField)
                    .foregroundColor(.black)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                Button(action: transfer) {
                    Text("Transfer")
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
                
                Spacer()
                
                ConfettiCannon(counter: $confettiCounter, confettis: [.text("Ƶ")], colors: [.red, .orange, .green], confettiSize: 20)
            }
        }
        .padding([.leading, .trailing], 27.5)
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
        .onAppear {
            userAuth.updateUserData()
            userAuth.updateDGPData()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .alert(isPresented: $showErrorMessage) { () -> Alert in
            Alert(title: Text("Error"),
                  message: Text(errorMessageText),
                  dismissButton: .default(Text("Ok"))
            )
        }
    }
    
    func submitActiveKey() {
        userAuth.changeActiveKey(key: tmpActiveKey)
    }
    
    func transfer() {
        isLoading = true
        var result: UINotificationFeedbackGenerator.FeedbackType = .error
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        defer {
            notificationFeedbackGenerator.notificationOccurred(result)
        }
        guard let amount = amount else {
            return
        }
        result = .success
        print("Transfer: \(amount)")
        viz.transfer(initiator: userAuth.login, activeKey: userAuth.activeKey, receiver: receiver, amount: amount, memo: memo) { (err) in
            if err != nil {
                errorMessageText = err.debugDescription
                showErrorMessage = true
            } else {
                receiver = ""
                self.amount = nil
                self.empty = true
                memo = ""
                confettiCounter += 1
                userAuth.updateUserData()
            }
            isLoading = false
        }
        
    }
}

struct TransferView_Previews: PreviewProvider {
    static var previews: some View {
        TransferView()
    }
}
