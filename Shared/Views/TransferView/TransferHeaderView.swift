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
            Text("🧑 \(String(localized: "Account")): \(auth.login)")
            Text("💰 \(String(localized: "Liquid balance")): \(VIZHelper.toFormattedString(auth.balance))")
                .lineLimit(1)
                .fixedSize()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.headline)
        .foregroundColor(.white)
    }
}
