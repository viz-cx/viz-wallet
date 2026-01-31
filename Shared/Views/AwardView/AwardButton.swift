//
//  AwardButton.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/31/26.
//

import SwiftUI

struct AwardButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Award".localized())
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.green.opacity(0.95))
                .cornerRadius(15)
        }
    }
}
