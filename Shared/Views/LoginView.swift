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
    
    // MARK: - View
    var body: some View {
        VStack() {
            LottieView(name: "33598-hammock")
                .padding([.top], 30)
            
            ActivityIndicator(isAnimating: $isLoading, style: .large, color: .yellow)
            
            VStack(alignment: .leading, spacing: 15) {
                TextField("Login", text: $login)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                TextField("Private regular key", text: $regularKey)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                Button(action: signIn) {
                    Text("Sign In")
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
            .padding(.bottom, 30)

            Spacer()
            
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                    .colorInvert()
                NavigationLink(destination: RegistrationView()) {
                    Text("Sign Up")
                        .foregroundColor(.black)
                        .colorInvert()
                }
            }
        }
        .padding([.leading, .trailing], 27.5)
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    func signIn() {
        isLoading = true
        // TODO: return error and change isLoading to false
        userAuth.auth(login: login, regularKey: regularKey)
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
        }
    }
}
#endif
