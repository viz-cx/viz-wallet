//
//  TransferActionsView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/29/26.
//

import SwiftUI

struct TransferActionsView: View {
    @ObservedObject var vm: TransferViewModel
    let onTransfer: () -> Void
    
    var body: some View {
        if vm.isLoading {
            ActivityIndicator(
                isAnimating: $vm.isLoading,
                style: .large,
                color: .yellow
            )
        } else {
            Button(action: onTransfer) {
                Text("Transfer".localized())
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.orange.opacity(0.95))
                    .cornerRadius(15)
            }
        }
    }
}
