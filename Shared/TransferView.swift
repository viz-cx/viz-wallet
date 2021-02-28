//
//  TransferView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 28.02.2021.
//

import SwiftUI

struct TransferView: View {
    var body: some View {
        LottieView(name:"31675-programming")
            .background(
                LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all))
    }
}

struct TransferView_Previews: PreviewProvider {
    static var previews: some View {
        TransferView()
    }
}
