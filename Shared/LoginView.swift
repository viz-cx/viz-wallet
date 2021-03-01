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
        
    // MARK: - View
    var body: some View {
        VStack() {
            LottieView(name:"33598-hammock")
                .padding([.top, .bottom], 40)
            
            VStack(alignment: .leading, spacing: 15) {
                TextField("Login", text: $login)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                TextField("Private regular key", text: $regularKey)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
            }.padding([.leading, .trailing], 27.5)
            
            Button(action: signIn) {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.green)
                    .cornerRadius(15.0)
                    .shadow(radius: 10.0, x: 20, y: 10)
            }
            .padding(.top, 10)
            .padding(.bottom, 30)
            
            Spacer()
            
            HStack(spacing: 0) {
                Text("Don't have an account? ")
                    .colorInvert()
                Button(action: {}) {
                    Text("Sign Up")
                        .foregroundColor(.black)
                }
                .colorInvert()
            }
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all))
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    func signIn() {
        userAuth.auth(login: login, regularKey: regularKey)
    }
}

extension Color {
    static var themeTextField: Color {
        return Color(red: 220.0/255.0, green: 230.0/255.0, blue: 230.0/255.0, opacity: 1.0)
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
