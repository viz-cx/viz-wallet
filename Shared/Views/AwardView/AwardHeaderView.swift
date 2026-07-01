//
//  AwardUserInfoView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/31/26.
//

import SwiftUI

struct AwardHeaderView: View {
    let userAuth: UserAuthStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("🧑 \(String(localized: "Login")): \(userAuth.login)")
            Text("🔋 \(String(localized: "Energy")): \(energyText)")
            Text("🏆 \(String(localized: "Social capital")): \(vestingText)")
                .lineLimit(1)
        }
        .font(.headline)
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
//        .background(Color.black.opacity(0.15))
//        .cornerRadius(20)
    }
    
    private var energyText: String {
        String(format: "%.2f%%", Double(userAuth.energy) / 100)
    }
    
    private var vestingText: String {
        VIZHelper.toFormattedString(userAuth.effectiveVestingShares)
    }
}
