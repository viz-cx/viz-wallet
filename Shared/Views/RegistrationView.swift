//
//  RegistrationView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 04.03.2021.
//

import SwiftUI

struct RegistrationView: View {
    @State private var login: String = ""
    @State private var code: String = ""
    
    @State private var showErrorMessage: Bool = false
    @State private var errorMessageText: String = ""
    
    var body: some View {
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
            
            Spacer()
            
            HStack(spacing: 0) {
                Text("Don't have an invite code? ".localized())
                    .colorInvert()
                Text("Sign Up".localized())
                    .foregroundColor(.black)
                    .colorInvert()
                    .onTapGesture {
                        var link = "https://reg.readdle.me/?set_lang=en"
                        if case .russian = Locales.current {
                            link = "https://reg.readdle.me/?set_lang=ru"
                        }
                        guard let url = URL(string: link) else { return }
                        UIApplication.shared.open(url)
                    }
            }
            .padding(.bottom, 15)
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
        errorMessageText = "Feature not released yet".localized()
        showErrorMessage = true
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
