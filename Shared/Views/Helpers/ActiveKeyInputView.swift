//
//  ActiveKeyView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 06.03.2021.
//

import SwiftUI

struct ActiveKeyInputView: View {
    @EnvironmentObject private var userAuth: UserAuthStore
    @State private var activeKey = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Text("Active key not added yet".localized())
                .padding()
                .frame(maxWidth: .infinity, alignment: Alignment.center)
                .cornerRadius(20.0)
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("Private active key".localized(), text: $activeKey)
                .accessibility(identifier: "active")
                .padding()
                .background(Color.themeTextField)
                .foregroundColor(.black)
                .cornerRadius(20.0)
                .disableAutocorrection(true)
                .autocapitalization(.none)
            
                Button(action: {
                    Task {
                        do {
                            try await userAuth.changeActiveKey(key: activeKey)
                        } catch {
                            print(error.localizedDescription) // TODO: show for user
                        }
                    }
                }, label: {
                Text("Save".localized())
                    .accessibility(identifier: "save")
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
            })
            
            Spacer()
        }
    }
}

#Preview {
    ActiveKeyInputView()
}
