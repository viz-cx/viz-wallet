//
//  AwardSlider.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/31/26.
//

import SwiftUI

struct AwardSlider: View {
    @Binding var percent: Double
    let maxPercent: Double
    let rewardProvider: () -> Double
    
    var body: some View {
        if maxPercent >= 0.01 {
            VStack(spacing: 8) {
                Slider(
                    value: $percent,
                    in: 0.01...maxPercent,
                    step: 0.01
                )
                .accentColor(.green)
                
                
                HStack {
                    Text(String(format: "%.2f %%", percent))
                    Spacer()
                    Text("≈ \(String(format: "%.3f", rewardProvider())) Ƶ")
                }
                .foregroundColor(.white)
            }
        }
    }
}
