//
//  ReceiverView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/31/26.
//

import SwiftUI

struct ReceiverView: View {
    @Binding var isShowingScanner: Bool
    @Binding var receiver: String
    
    var body: some View {
        HStack {
            TextField("Receiver", text: $receiver)
                .padding()
                .background(Color.themeTextField)
                .foregroundColor(.black)
                .cornerRadius(20)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)

            QRScannerButton(isShowingScanner: $isShowingScanner) { receiver in
                self.receiver = receiver
            }
        }
    }
}
