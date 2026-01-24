//
//  ConfettiView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/24/26.
//

import SwiftUI
import ConfettiSwiftUI

struct ConfettiWrapper: View {
    @Binding var trigger: Int
    private let confettiSize = 20.0
    
    var body: some View {
        ConfettiCannon(
            trigger: $trigger,
            num: 100,
            confettis: [.text("Ƶ")],
            colors: [.red, .orange, .green],
            confettiSize: confettiSize
        )
    }
}


extension View {
    func confetti(trigger: Binding<Int>) -> some View {
        overlay(
            ConfettiWrapper(trigger: trigger)
        )
    }
}
