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
            HStack {
                TextField("Receiver".localized(), text: $vm.receiver)
                    .padding()
                    .background(Color.themeTextField)
                    .foregroundColor(.black)
                    .cornerRadius(20)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                
                Image(systemName: "qrcode.viewfinder")
                    .font(.largeTitle)
                    .colorInvert()
                    .buttonStyle(PlainButtonStyle())
                    .onTapGesture {
                        vm.isShowingScanner = true
                    }
                    .sheet(isPresented: $vm.isShowingScanner, content: {
                        CodeScannerView(codeTypes: [.qr], scanMode: .oncePerCode, simulatedData: "id") { result in
                            switch result {
                            case .success(let str):
                                if str.hasPrefix("viz://"), let atSymbolIdx = str.firstIndex(of: "@") {
                                    let range = str.index(after: atSymbolIdx)..<str.endIndex
                                    vm.receiver = String(str[range])
                                    vm.isShowingScanner = false
                                }
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    })
            }
            
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
