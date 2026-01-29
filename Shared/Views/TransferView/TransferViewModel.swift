//
//  TransferViewModel.swift
//  viz-wallet
//
//  Created by Vladimir Babin on 1/29/26.
//

import Foundation

@MainActor
final class TransferViewModel: ObservableObject {
    @Published var receiver = ""
    @Published var amount: Double?
    @Published var memo = ""
    @Published var isShowingScanner = false
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorText = ""
    @Published var confetti = 0
    
    func clampAmount(to balance: Double) {
        guard let amount, amount > balance else { return }
        self.amount = balance
    }
    
    func transfer(
        viz: VIZHelper,
        auth: UserAuth
    ) async {
        guard let amount else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await viz.transfer(
                initiator: auth.login,
                activeKey: auth.activeKey,
                receiver: receiver,
                amount: amount,
                memo: memo
            )
            
            receiver = ""
            self.amount = nil
            memo = ""
            confetti += 1
            
            await auth.updateUserData()
        } catch {
            errorText = error.localizedDescription
            showError = true
        }
    }
}
