//
//  TransferView.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 28.02.2021.
//

import SwiftUI

struct TransferView: View {
    @EnvironmentObject private var userAuth: UserAuth
    @StateObject private var vm = TransferViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                if userAuth.activeKey.isEmpty {
                    ActiveKeyInputView()
                } else {
                    TransferHeaderView(auth: userAuth)
                    
                    TransferFormView(vm: vm, balance: userAuth.balance)
                    
                    TransferActionsView(vm: vm) {
                        Task {
                            await vm.transfer(
                                viz: VIZHelper.shared,
                                auth: userAuth
                            )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .confetti(trigger: $vm.confetti)
            .alert("Error".localized(), isPresented: $vm.showError) {
                Button("Ok", role: .cancel) {}
            } message: {
                Text(vm.errorText)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.purple, .blue]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil,
                    from: nil,
                    for: nil
                )
            }
        )
    }
}

#Preview {
    let showActiveKeyPreview = true
    let auth = UserAuth()
    let randomKey = "5KLTkMZc3oRDAcdKeTv22sh4F2mB6rewyPDU4FENc4oYZ5DFBpe"
    try? auth.changeActiveKey(key: randomKey)
    return TransferView()
        .environmentObject(auth)
}
