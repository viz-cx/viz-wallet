//
//  ConfettiView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/24/26.
//

import SwiftUI
import ConfettiSwiftUI

extension View {
    
    func confetti(trigger: Binding<Int>) -> some View {
        confettiCannon(
            trigger: trigger,
            num: 100,
            confettis: [.text("Ƶ")],
            colors: [.red, .orange, .green],
            confettiSize: 20
        )
    }
}
