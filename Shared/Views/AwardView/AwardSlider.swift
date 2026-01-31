//
//  AwardSlider.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/31/26.
//

import SwiftUI

struct AwardSlider: View {
    @Binding var percent: Double
    let reward: Double
    
    var body: some View {
        VStack(spacing: 8) {
            Slider(value: $percent, in: 0.01...100, step: 0.01)
                .accentColor(.green)
            
            HStack {
                Text(String(format: "%.2f %%", percent))
                Spacer()
                Text("≈ \(String(format: "%.3f", reward)) Ƶ")
            }
            .foregroundColor(.white)
        }
    }
}
