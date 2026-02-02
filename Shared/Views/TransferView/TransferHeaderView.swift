//
//  TransferHeaderView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/29/26.
//

import SwiftUI

struct TransferHeaderView: View {
    let auth: UserAuthStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🧑 \("Account".localized()): \(auth.login)")
            Text("💰 \("Liquid balance".localized()): \(VIZHelper.toFormattedString(auth.balance))")
                .lineLimit(1)
                .fixedSize()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.headline)
        .foregroundColor(.white)
    }
}
