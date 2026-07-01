//
//  ActiveKeyView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 06.03.2021.
//

import os
import SwiftUI

private let log = Logger(subsystem: "cx.viz.viz-wallet", category: "auth")

struct ActiveKeyInputView: View {
    @Environment(UserAuthStore.self) private var userAuth
    @State private var activeKey = ""
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            
            Text("Active key not added yet")
                .padding()
                .frame(maxWidth: .infinity, alignment: Alignment.center)
                .cornerRadius(20.0)
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("Private active key", text: $activeKey)
                .accessibility(identifier: "active")
                .padding()
                .background(Color.themeTextField)
                .foregroundColor(.black)
                .cornerRadius(20.0)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
            
                Button(action: {
                    Task {
                        do {
                            try await userAuth.changeActiveKey(key: activeKey)
                        } catch {
                            // TODO: surface this error to the user
                            log.error("Failed to change active key: \(error, privacy: .public)")
                        }
                    }
                }, label: {
                Text("Save")
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
