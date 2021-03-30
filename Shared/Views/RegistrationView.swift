//
//  RegistrationView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 04.03.2021.
//

import SwiftUI
import VIZ

struct RegistrationView: View {
    private let viz = VIZHelper()
    
    @EnvironmentObject private var userAuth: UserAuth
    
    @State private var login: String = ""
    @State private var code: String = ""
    
    @State private var confettiCounter = 0
    @State private var showErrorMessage: Bool = false
    @State private var errorMessageText: String = ""
    @State private var isLoading = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Text("Sign Up with an invite code".localized())
                    .padding()
                    .frame(maxWidth: .infinity, alignment: Alignment.leading)
                    .cornerRadius(20.0)
                    .font(.headline)
                    .foregroundColor(.white)
                
                TextField("Invite code".localized(), text: $code)
                    .padding()
                    .background(Color.themeTextField)
                    .foregroundColor(.black)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                TextField("Login", text: $login)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                if isLoading {
                    ActivityIndicator(isAnimating: $isLoading, style: .large, color: .yellow)
                } else {
                    Button(action: registration) {
                        Text("Sign Up".localized())
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
                }
                
                VStack(spacing: 10) {
                    if !userAuth.registrationLogin.isEmpty {
                        Text("Attention! Be sure to copy these keys to a safe place".localized())
                            .bold()
                            .foregroundColor(.white)
                            .onTapGesture {
                                copyToClipboard()
                            }
                        Text(registrationText())
                            .foregroundColor(.white)
                            .onTapGesture {
                                copyToClipboard()
                            }
                    } else {
                        Text("You can ask invite in telegram group @viz_cx".localized())
                            .foregroundColor(.white)
                            .onTapGesture {
                                guard let url = URL(string: "https://t.me/viz_cx") else { return }
                                UIApplication.shared.open(url)
                            }
                    }
                }
                
                ConfettiCannon(counter: $confettiCounter, confettis: [.text("Ƶ")], colors: [.red, .orange, .green], confettiSize: 20)
                
                Spacer()
            }
        }
        .padding([.leading, .trailing], 16.0)
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        )
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
    
    func registration() {
        isLoading = true
        var result: UINotificationFeedbackGenerator.FeedbackType = .error
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        
        let password = userAuth.registrationPassword
        viz.inviteRegistration(inviteSecret: code, accountName: login, password: password, callback: { error in
            if let error = error {
                errorMessageText = error.localizedDescription
                showErrorMessage = true
            } else {
                userAuth.registrationLogin = login
                confettiCounter += 1
                code = ""
                login = ""
                result = .success
                viz.accountUpdate(accountName: login, password: password) { (error) in
                    if let error = error {
                        errorMessageText = error.localizedDescription
                        showErrorMessage = true
                    }
                }
            }
            notificationFeedbackGenerator.notificationOccurred(result)
            isLoading = false
        })
    }
    
    func randomString(of length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var s = ""
        for _ in 0 ..< length {
            s.append(letters.randomElement()!)
        }
        return s
    }
    
    private func copyToClipboard() {
        UIPasteboard.general.string = registrationText()
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func registrationText() -> String {
        do {
            return """
            Login: \(userAuth.registrationLogin)
            Private regular key: \(String(try viz.privateKey(fromAccount: userAuth.registrationLogin, password: userAuth.registrationPassword, type: .regular)))
            Private active key: \(String(try viz.privateKey(fromAccount: userAuth.registrationLogin, password: userAuth.registrationPassword, type: .active)))
            Private master key: \(String(try viz.privateKey(fromAccount: userAuth.registrationLogin, password: userAuth.registrationPassword, type: .master)))
            Private memo key: \(String(try viz.privateKey(fromAccount: userAuth.registrationLogin, password: userAuth.registrationPassword, type: .memo)))
            """
        } catch {
            return ""
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
