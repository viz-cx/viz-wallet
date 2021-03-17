//
//  RegistrationView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 04.03.2021.
//

import SwiftUI

struct RegistrationView: View {
    
    @State private var code: String = ""
    
    var body: some View {
        VStack {
            Text("Sign Up with an invite code".localized())
                .padding()
                .frame(maxWidth: .infinity, alignment: Alignment.leading)
                .cornerRadius(20.0)
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                TextField("Invite code", text: $code)
                    .padding()
                    .background(Color.themeTextField)
                    .foregroundColor(.black)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
            }
            
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
    }
    func registration() {
        print("reg!!")
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
