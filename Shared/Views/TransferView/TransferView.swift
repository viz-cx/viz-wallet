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
        .scrollDismissesKeyboard(.interactively)
    }
}


struct TransferView_Previews: PreviewProvider {
    static let showActiveKeyPreview = true
    static let auth = UserAuth()
    
    init() {
        let randomKey = "5KLTkMZc3oRDAcdKeTv22sh4F2mB6rewyPDU4FENc4oYZ5DFBpe"
        if TransferView_Previews.showActiveKeyPreview {
            try! TransferView_Previews.auth.changeActiveKey(key: randomKey)
        }
    }
    
    static var previews: some View {
        TransferView()
            .environmentObject(auth)
    }
}
