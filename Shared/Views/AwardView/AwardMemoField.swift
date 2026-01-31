//
//  AwardMemoField.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/31/26.
//

import SwiftUI

struct AwardMemoField: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Memo".localized(), text: $text)
            .padding()
            .background(Color.themeTextField)
            .foregroundColor(.black)
            .cornerRadius(20)
            .disableAutocorrection(true)
            .textInputAutocapitalization(.never)
    }
}
