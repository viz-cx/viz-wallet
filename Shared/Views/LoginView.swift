//
//  LoginView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 22.02.2021.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var userAuth: UserAuth
    @State private var login = ""
    @State private var regularKey = ""
    @State private var isLoading = false
    @State private var showSignUp = false
    @State private var showErrorMessage: Bool = false
    @State private var errorMessageText: String = ""
    
    // MARK: - View
    var body: some View {
        VStack() {
            LottieView(name: "39387-business-team")
            VStack() {
                ActivityIndicator(isAnimating: $isLoading, style: .large, color: .yellow)
                
                VStack(alignment: .leading, spacing: 15) {
                    TextField("Login", text: $login)
                        .padding()
                        .background(Color.themeTextField)
                        .cornerRadius(20.0)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    TextField("Private regular key".localized(), text: $regularKey)
                        .padding()
                        .background(Color.themeTextField)
                        .cornerRadius(20.0)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                    
                    Button(action: signIn) {
                        Text("Sign In".localized())
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
                .padding(.bottom, 25)
                
                Spacer()
                
                HStack(spacing: 0) {
                    Text("Don't have an account? ".localized())
                        .colorInvert()
                    Text("Sign Up".localized())
                        .foregroundColor(.black)
                        .colorInvert()
                        .onTapGesture {
                            // showSignUp = true
                            let locale = Locale.preferredLanguages.count > 0 ? Locale.preferredLanguages[0] : NSLocale.current.languageCode
                            var link = "https://reg.readdle.me/?set_lang=en"
                            if locale == "ru" || locale == "ru-RU" {
                                link = "https://reg.readdle.me/?set_lang=ru"
                            }
                            guard let url = URL(string: link) else { return }
                            UIApplication.shared.open(url)
                        }
                        .sheet(isPresented: $showSignUp, content: {
                            RegistrationView()
                        })
                }
                .padding(.bottom, 15)
                
            }
            .padding([.leading, .trailing], 27.5)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
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
    
    func signIn() {
        isLoading = true
        userAuth.auth(login: login, regularKey: regularKey) { error in
            if let error = error {
                errorMessageText = error.localizedDescription
                showErrorMessage = true
            }
            isLoading = false
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView().environmentObject(UserAuth())
            LoginView().environmentObject(UserAuth())
        }
    }
}
#endif
