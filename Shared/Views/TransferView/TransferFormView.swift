//
//  TransferFormView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/29/26.
//

import SwiftUI
import CodeScanner

struct TransferFormView: View {
    @ObservedObject var vm: TransferViewModel
    let balance: Double
    
    var body: some View {
        VStack(spacing: 12) {
            ReceiverView(isShowingScanner: $vm.isShowingScanner, receiver: $vm.receiver)
            
            CurrencyTextField(
                "Amount".localized(),
                value: $vm.amount,
                alwaysShowFractions: true,
                numberOfDecimalPlaces: 2,
                currencySymbol: "Ƶ"
            )
            .onChange(of: vm.amount) {
                vm.clampAmount(to: balance)
            }
            .keyboardType(UIKeyboardType.decimalPad)
            .padding()
            .background(Color.themeTextField)
            .foregroundColor(.black)
            .cornerRadius(20.0)
            .disableAutocorrection(true)
            .autocapitalization(.none)

            
            TextField("Memo".localized(), text: $vm.memo)
                .padding()
                .background(Color.themeTextField)
                .foregroundColor(.black)
                .cornerRadius(20)
                .disableAutocorrection(true)
                .autocapitalization(.none)
        }
    }
}
