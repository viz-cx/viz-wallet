//
//  AwardView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 23.02.2021.
//

import SwiftUI

struct AwardView: View {
    @State private var receiver = ""
    @State private var percent = 5.0
    @State private var memo = ""
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 15) {
                TextField("Receiver", text: $receiver)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                TextField("Memo", text: $memo)
                    .padding()
                    .background(Color.themeTextField)
                    .cornerRadius(20.0)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                VStack {
                    Slider(value: $percent, in: 0.01...100.0, step: 0.01)
                    HStack {
                        Text(String(format: "%.2f", percent) + " %")
                        Text("≈\(percent * 0.55) Ƶ")
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                
                
                
            }.padding([.leading, .trailing], 27.5)
        }
    }
}

struct AwardView_Previews: PreviewProvider {
    static var previews: some View {
        AwardView()
    }
}
