//
//  SettingsView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 27.02.2021.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        LottieView(name:"31675-programming")
            .background(
                LinearGradient(gradient: Gradient(colors: [.purple, .blue]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
